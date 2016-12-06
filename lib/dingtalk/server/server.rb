require 'json'
require 'rails'

module Dingtalk

  class Server

    ACCESS_TOKEN_CACHE_KEY = 'Dingtalk::Server::ACCESS_TOKEN_CACHE_KEY'
    JSAPI_TICKET_CACHE_KEY = 'Dingtalk::Server::JSAPI_TICKET_CACHE_KEY'

    # 构造函数
    # @param [String] corp_id 钉钉提供的ID
    # @param [String] corp_secret 钉钉提供的密码
    def initialize(corp_id, corp_secret)
      @corp_id = corp_id
      @corp_secret = corp_secret
    end

    # 查询AccessToken
    # @return [String] 直接返回token，如果失败则返回nil
    def query_access_token
      token = query_access_token_with_cache
      if token.nil? || token.empty?
        # 防止因为一些网络错误，缓存了空值，造成在缓存期内服务不可用
        Rails.cache.delete(ACCESS_TOKEN_CACHE_KEY)
        token = query_access_token_with_cache
      end
      token
    end

    private

    # 查询AccessToken，带缓存
    # @return [String] 直接返回token，如果失败则返回nil
    def query_access_token_with_cache
      Rails.cache.fetch(ACCESS_TOKEN_CACHE_KEY, expires_in: 1.hours) do
        query_access_token_with_direct
      end
    end

    # 查询AccessToken，不带缓存
    # @return [String] 直接返回token，如果失败则返回nil
    def query_access_token_with_direct
      uri = URI(INTERFACE_URL + '/gettoken?' + 'corpid=' + @corp_id + '&corpsecret=' + @corp_secret)
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      @token = result['access_token']
    end
  end
end