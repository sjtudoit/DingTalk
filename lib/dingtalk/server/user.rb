require 'net/http'
require_relative 'server'

module Dingtalk

  class Server

    # 查询部门列表
    # @return [Array] 返回部门id的数组，失败返回nil或空数组
    def query_departments()
      @token ||= query_access_token
      uri = URI(INTERFACE_URL + '/department/list?' + 'access_token=' + @token)
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      departments = result['department']
      return nil if departments.nil?
      departments.select{|d| d['id']}.map{|d| d['id']}
    end

    # 查询单个部门的成员列表
    # @param [Fixnum] 部门id
    # @return [Array] 返回该部门用户的数组，失败返回nil或空数组
    def query_users_in_one_department(department_id)
      @token ||= query_access_token
      uri = URI(INTERFACE_URL + '/user/simplelist?' + 'access_token=' + @token + '&department_id=' + department_id.to_s)
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      result['userlist'].map do |user_data|
        UserInfo.new user_data
      end
    end

    # 查询所有用户
    # @return [Array] 返回所有用户的数组，失败返回nil或空数组
    def query_all_users()
      departments = query_departments
      return nil if departments.nil?
      all_users = []
      departments.each do |id|
        department_users = query_users_in_one_department(id)
        self.class.merge_users!(all_users, department_users)
      end
      all_users
    end

    # 合并用户，将"from"中的users合并进"into"
    # @param [Array] into 合并结束之后，这个值有可能发生更改
    # @param [Array] from
    # @return [Array] 合并后的用户列表
    def self.merge_users!(into, from)
      from.each do |new_user|
        find_same_user = false
        into.each do |original_user|
          if same_user?(original_user, new_user)
            find_same_user = true
            break
          end
        end
        into << new_user unless find_same_user
      end
      into
    end

    # 判断是否相同用户
    # @param [User] left
    # @param [User] right
    # @return [TrueClass/FalseClass]
    def self.same_user?(left, right)
      left.userid == right.userid
    end
  end

  class UserInfo

    attr_reader :name, :userid

    # 构造
    # @param [Hash] data 钉钉返回的单个用户数据
    def initialize(data)
      @name = data['name']
      @userid = data['userid']
    end
  end
end
