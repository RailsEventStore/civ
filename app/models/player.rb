class Player < ApplicationRecord
  def slack_id
    slack_identifier || slack_name
  end
end
