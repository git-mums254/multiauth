module Multiauth
  class SessionsController < Devise::OmniauthCallbacksController
    include Devise::Controllers::Rememberable
    skip_before_filter :verify_authenticity_token

    def auth
      # see http://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
      fields = env["omniauth.auth"] || request.env['rack.auth']

      if user_signed_in?
        self.current_user.connect(fields)
        if respond_to?(:after_sign_in_path_for)
          redirect_to after_sign_in_path_for(self.current_user)
        else
          redirect_to user_path(self.current_user)
        end
        return
      elsif (@user = User.authenticate(fields)) && (!@user.new_record?)
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => fields["provider"].titleize
        @user.remember_me = true
        @user.extend_remember_period = true
        remember_me(@user)

        sign_in_and_redirect(@user, :event => :authentication)
        return
      end

      redirect_to new_session_path(:user)
    end
    alias_method :twitter, :auth
    alias_method :identica, :auth
    alias_method :open_id, :auth
    alias_method :linked_in, :auth
    alias_method :facebook, :auth
    alias_method :google, :auth
    alias_method :flattr, :auth
    alias_method :sso, :auth

    protected
  end
end
