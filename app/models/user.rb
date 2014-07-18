require 'omniauth/identity'
class User < OmniAuth::Identity::Models::ActiveRecord
  has_many :authentications

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence   => true,
            :format     => { :with => email_regex },
            :uniqueness => { :case_sensitive => false }

  def self.create_with_omniauth(auth)
    create(name: auth['info']['name'], email: auth['info']['email'])
  end

  def self.create_with_omniauth_others(auth)
    p = rand(36**10).to_s(36)
    create(name: auth['info']['name'], email: auth['info']['email'], password: p, password_confirmation: p)
  end

end