require 'digest/sha1'

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

    # 生成jsapi的配置
    # @param [String] url
    # @return [Hash] 如果出错返回nil
    def create_jsapi_config(url)
      jsapi_ticket = query_jsapi_ticket
      return nil if jsapi_ticket.nil?
      noncestr = SecureRandom.uuid.to_s
      timestamp = Time.now.to_i
      result = {}
      result[:corpId] = @corp_id
      result[:timeStamp] = timestamp
      result[:nonceStr] = noncestr
      result[:signature] = sign(noncestr, jsapi_ticket, timestamp, self.class.pretreat_url(url))
      result
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

    # jsapi签名
    # @param [String] noncestr
    # @param [String] jsapi_ticket
    # @param [String] timestamp
    # @param [String] url
    # @return [String]
    def sign(noncestr, jsapi_ticket, timestamp, url)
      string_to_sign = "jsapi_ticket=#{jsapi_ticket}&noncestr=#{noncestr}&timestamp=#{timestamp}&url=#{url}"
      Digest::SHA1.hexdigest string_to_sign
    end

    # 根据钉钉文档的要求预处理url
    def self.pretreat_url(url)
      uri = URI(url)
      uri.fragment = nil
      URI.unescape(uri.to_s)
    end
  end
end