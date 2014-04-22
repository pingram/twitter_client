class Status < ActiveRecord::Base
  validates :twitter_status_id, :body, :twitter_user_id, presence: true
  validates :twitter_status_id, uniqueness: true

  def self.fetch_by_twitter_user_id!(twitter_user_id)
    #NOTE: only pulls 20 most recent statuses for user
    json_statuses = TwitterSession.get("statuses/user_timeline",
                    { :user_id => twitter_user_id })
    self.parse_json(json_statuses, twitter_user_id)
  end

  def self.parse_json(json_statuses, twitter_user_id)
    previously_saved = Status
                       .all
                       .where(:twitter_user_id => twitter_user_id)
                       .pluck(:twitter_status_id)

    [].tap do |parsed_statuses|
      json_statuses.map do |status|
        unless previously_saved.include?(status["id_str"])
          new_status = Status.new(
                       :twitter_status_id => status["id_str"],
                       :body => status["text"],
                       :twitter_user_id => status["user"]["id"].to_s
                    )
          new_status.save!
          parsed_statuses << new_status
        end
      end
    end
  end

  def self.post(body, twitter_user_id)
    TwitterSession.post('statuses/update',
                        { :status => body })
    self.fetch_by_twitter_user_id!(twitter_user_id)
  end

end
