require 'spec_helper'

require 'dingtalk'

describe Dingtalk do
  it 'has a version number' do
    expect(Dingtalk::VERSION).not_to be nil
  end

  Dingtalk.corpid = ENV['SJTUDOIT_DINGTALK_CORPID']
  Dingtalk.corpsecret = ENV['SJTUDOIT_DINGTALK_CORPSECRET']
  let(:server) { Dingtalk::Server.new(Dingtalk.corpid, Dingtalk.corpsecret) }

  it 'query access token' do
    token = server.query_access_token
    expect(token).not_to be nil
  end

  it 'query departments' do
    departments = server.query_departments
    expect(departments).not_to be nil
    expect(departments.empty?).not_to be true
  end

  it 'query root department users' do
    users = server.query_users_in_one_department(1)
    expect(users).not_to be nil
  end

  it 'merge users correct' do
    into = [Dingtalk::UserInfo.new({"name" => "xxx", "userid" => "1"}),
            Dingtalk::UserInfo.new({"name" => "yyy", "userid" => "2"}),
            Dingtalk::UserInfo.new({"name" => "zzz", "userid" => "3"})]
    from = [Dingtalk::UserInfo.new({"name" => "xxx", "userid" => "1"}),
            Dingtalk::UserInfo.new({"name" => "aaa", "userid" => "4"})]
    Dingtalk::Server.merge_users!(into, from)
    expect(into.length).to eql(4)
  end

  it 'query all users' do
    all_users = server.query_all_users
    expect(all_users).not_to be nil
  end
end

describe 'cache' do

  Rails.cache = ActiveSupport::Cache.lookup_store(:memory_store)
  Dingtalk.corpid = ENV['SJTUDOIT_DINGTALK_CORPID']
  Dingtalk.corpsecret = ENV['SJTUDOIT_DINGTALK_CORPSECRET']
  let(:server) { Dingtalk::Server.new(Dingtalk.corpid, Dingtalk.corpsecret) }

  it 'cache access token correct' do
    token_one = server.query_access_token
    token_two = Rails.cache.fetch(Dingtalk::Server.const_get :ACCESS_TOKEN_CACHE_KEY)
    expect(token_one).to eql(token_two)
  end

  it 'correct itself when cache nil' do
    token_two = Rails.cache.write(Dingtalk::Server.const_get(:ACCESS_TOKEN_CACHE_KEY), nil)
    token = server.query_access_token
    expect(token).not_to be nil
  end

  it 'correct itself when cache empty' do
    token_two = Rails.cache.write(Dingtalk::Server.const_get(:ACCESS_TOKEN_CACHE_KEY), '')
    token = server.query_access_token
    expect(token.empty?).not_to be true
  end
end
