require 'omniauth-oauth2'
require 'base64'

module OmniAuth
  module Strategies
    class HmppsSso < OmniAuth::Strategies::OAuth2
      option :name, 'hmpps_sso'

      # :nocov:
      # Nocov temporary until we get user details from custody API
      info do
        {
          username: token_info.fetch('user_name'),
          caseload: raw_info.fetch('activeNomisCaseload')
        }
      end

      def build_access_token
        options.token_params[:headers] = { 'Authorization' => basic_auth_header }
        super
      end

      def token_info
        access_token.params
      end

      def raw_info
        @raw_info ||= Nomis::Custodyapi::Api.fetch_nomis_staff_details
      end

      # Without this login with sso breaks.
      # This issued was first identified in the Prison Visits Booking service. See
      # https://github.com/ministryofjustice/prison-visits-2/commit/1aaf9fba367b084e1127e3269efbf8e883f3c45b
      # Issue has still not been resolved by the library owners.
      # Fix implemented as suggested here:
      # https://github.com/intridea/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f#commitcomment-19809835
      # Other link about the issue: https://github.com/intridea/omniauth-oauth2/issues/81
      # omniauth-oauth2 after version 1.3.1 changed the way that the callback
      # url gets generated. This new version doesn't match the redirect uri as set in
      # SSO so login breaks.
      # The issue seems quite common among multiple SSO providers like Google,
      # Facebook, Dropbox, etc

      def callback_url
        full_host + script_name + callback_path
      end

    private

      # rubocop:disable Metrics/LineLength
      def basic_auth_header
        'Basic ' + Base64.urlsafe_encode64(
          "#{Rails.configuration.nomis_oauth_client_id}:#{Rails.configuration.nomis_oauth_client_secret}"
        )
      end
      # rubocop:enable Metrics/LineLength
      # :nocov:
    end
  end
end
