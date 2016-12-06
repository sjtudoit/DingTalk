module Dingtalk

  class Server

    # 查询jsapi_ticket
    # @return [String] 直接返回jsapi_ticket，如果失败则返回nil
    def query_jsapi_ticket
      jsapi_ticket = query_jsapi_ticket_with_cache
      if jsapi_ticket.nil? || jsapi_ticket.empty?
        # 防止因为一些网络错误，缓存了空值，造成在缓存期内服务不可用
        Rails.cache.delete(JSAPI_TICKET_CACHE_KEY)
        jsapi_ticket = query_jsapi_ticket_with_cache
      end
      jsapi_ticket
    end

    private

    # 查询jsapi_ticket，带缓存
    # @return [String] 直接返回jsapi_ticket，如果失败则返回nil
    def query_jsapi_ticket_with_cache
      Rails.cache.fetch(JSAPI_TICKET_CACHE_KEY, expires_in: 1.hours) do
        query_jsapi_ticket_with_direct
      end
    end

    # 查询jsapi_ticket，不带缓存
    # @return [String] 直接返回token，如果失败则返回nil
    def query_jsapi_ticket_with_direct
      token = query_access_token
      return nil if token.nil?

      uri = URI(INTERFACE_URL + '/get_jsapi_ticket?' + 'access_token=' + token + '&type=jsapi')
      response = Net::HTTP.get(uri)
      result = JSON.parse(response)
      @token = result['ticket']
    end
  end
end