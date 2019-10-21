# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :set_date, only: %i[show]
  before_action :forbid_not_mypage_user, only: %i[show]
  before_action :get_data, only: %i[show]
  before_action :get_chart, only: %i[show]
  before_action :get_engel, only: %i[show]
  before_action :only_not_google_user, only: %i[edit]

  def show
    @monthly_money = EstimateAmount.find_by(month: Date.today.month, year: Date.today.year, user: @user)
    @records = Record.where(user_id: @user.id).where(purchase_date: @first_day..@last_day).order(purchase_date: :desc).page(params[:page]).per(3)
    @count =  Record.where(user_id: @user.id).where(purchase_date: @first_day..@last_day).count
    respond_to do |format|
      format.html
      format.csv { send_data @user.records.generate_csv, filename: "records-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: 'ユーザー情報を更新しました'
    else
      respond_to do |format|
        format.js { render :error }
      end
    end
  end

  def destroy
    @user.destroy
    redirect_to root_path, notice: 'またのご利用をお待ちしております'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def set_date
    today = Date.today
    @last_day = Date.new(today.year, today.month, -1).strftime('%Y-%m-%d')
    @first_day = Date.new(today.year, today.month).strftime('%Y-%m-%d')
  end

  def forbid_not_mypage_user
    if current_user.id != @user.id
      redirect_to user_path(current_user), notice: '権限がありません'
    end
  end

  def get_data
    @data = {}
    [*@first_day..@last_day].each do |day|
      @data[day.to_s] = @user.records.where(purchase_date: day).map(&:purchase_price).sum
    end
  end

  def get_chart
    @chart = {}
    @labels = @user.records.where(purchase_date: @first_day..@last_day).map(&:label)
    @labels.each do |label|
      @chart[label.name.to_s] = label.records.where(user_id: @user.id).map(&:purchase_price).sum
    end
  end

  def get_engel
    @sum = @user.records.where(purchase_date: @first_day..@last_day).map(&:purchase_price).sum
    @food_cost = @user.records.where(purchase_date: @first_day..@last_day).select { |item| item.label.name == '食費' }.map(&:purchase_price).sum
    @engel = ((@food_cost / @sum.to_f) * 100).round if @sum != 0
  end

  def only_not_google_user
    if current_user.provider
      redirect_to user_path(current_user), notice: 'アクセスできません'
    end
  end
end
