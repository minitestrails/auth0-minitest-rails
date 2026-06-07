class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :auth0_uid, presence: true, uniqueness: true

  def self.find_or_create_from_auth0(auth_info)
    auth0_uid = auth_info["uid"]
    email =
      auth_info.dig("info", "email") ||
        auth_info.dig("extra", "raw_info", "email")
    name =
      auth_info.dig("info", "name") ||
        auth_info.dig("extra", "raw_info", "name")

    find_or_create_by!(auth0_uid: auth0_uid) do |user|
      user.email = email
      user.name = name
    end
  end
end
