require 'spec_helper'

require 'dingtalk'

describe Dingtalk do
  it 'has a version number' do
    expect(Dingtalk::VERSION).not_to be nil
  end

  id = ENV['SJTUDOIT_DINGTALK_CORPID']
  secret = ENV['SJTUDOIT_DINGTALK_CORPSECRET']
  let(:server) { Dingtalk::Server.new(id, secret) }

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
    into = [{"name"=>"xxx", "userid"=>"1"}, {"name"=>"yyy", "userid"=>"2"}, {"name"=>"zzz", "userid"=>"3"}]
    from = [{"name"=>"xxx", "userid"=>"1"}, {"name"=>"aaa", "userid"=>"4"}]
    Dingtalk::Server.merge_users!(into, from)
    expect(into.length).eql? 4
  end

  it 'query all users' do
    all_users = server.query_all_users
    expect(all_users).not_to be nil
  end
end
