class MySubscription < ActiveRecord::Base
  attr_accessible :developer_id, :word_add, :word_follow, :word_search
  belongs_to :developer
  belongs_to :subscription_model

  
  def self.decrement_limit(dev_id)

  	mySubscription = MySubscription.joins(:developer).where(:developer_id => dev_id).first
    old_limit = mySubscription.word_search
  	if old_limit > 0
  	mySubscription.word_search = old_limit - 1
    mySubscription.save
    return true
    else

      return false

    end
  end

  def self.search_word_permission(dev_id)
    mySubscription = MySubscription.joins(:developer).where(:developer_id => dev_id).first
  	if mySubscription.word_search > 0 
  		return true
  	else
  		return false
    end
  end

  def self.add_word_permission(dev_id)
     mySubscription = MySubscription.where(:developer => dev_id).first
  	if mysubscription.word_add > 0
  		return true
  	else 
  		return false
    end  	
  end

  def self.follow_word_permission(dev_id)
  	if mysubscription.word_follow > 0
  	    return true
  	else
  		return false
    end
  end  
end
