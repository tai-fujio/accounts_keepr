# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users', type: :feature do
  describe '新規登録機能' do
    before  do
      visit new_user_registration_path
      fill_in 'メールアドレス', with: 'test1@railstest.org'
      fill_in 'パスワード', with: 'testtest'
      fill_in '確認用パスワード', with: 'testtest'
    end

    it '登録できる' do
      fill_in '名前', with: 'test_user1'
      click_on '登録'
      expect(page).to have_content 'アカウント登録が完了しました。'
    end

    it '登録に失敗してエラーがでる' do
      fill_in '名前', with: 'あ' * 31
      click_on '登録'
      expect(page).to have_content 'は30文字以内で入力してください'
    end
  end

  describe 'ログイン/ログアウト機能' do
    before do
      user = FactoryBot.create(:user)
      visit new_user_session_path
      fill_in 'パスワード', with: 'testtest'
    end

    it 'ログインに成功する' do
      fill_in 'メールアドレス', with: 'test1@railstest.org'
      click_button 'ログイン'
      expect(page).to have_content 'ログインしました'
    end

    it 'ログアウトに成功する' do
      fill_in 'メールアドレス', with: 'test2@railstest.org'
      click_button 'ログイン'
      click_on 'ログアウト'
      expect(page).to have_content 'ログアウトしました'
    end

  end

  describe "Googel" do 
    it "googleでログイン認証できること"  do 
      google_user = FactoryBot.create(:google_user)
      visit root_path 
      click_on "Googleで登録/ログインする"
      sleep 1
      expect(page).to have_content "Google アカウントによる認証に成功しました"
    end
  end

end
