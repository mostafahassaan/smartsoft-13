class MySubscription < ActiveRecord::Base
  belongs_to :subscription_model
  attr_accessible :developer, :word_add, :word_follow, :word_search, :subscription_model_id
  belongs_to :developer
  validates :subscription_model_id, :presence => true
  # Author:
  #  Noha Hesham
  # Description:
  #  it finds the chosen subscription model by the developer 
  #  and sets the limits in the subscription model
  #  to the developers my subscription
  # success:
  #  the limits are set in the my subscription of the developer
  # failure:
  #  the limits are not put in the my subscription of the developer
  def self.choose(dev_id,sub_id)
      submodel = SubscriptionModel.find(sub_id)
      my_sub = MySubscription.where(:developer_id => dev_id).first
      if(my_sub == nil)
        my_sub = MySubscription.new
      end
      my_sub.developer_id = dev_id
      my_sub.word_search=submodel.limit_search
      my_sub.word_add=submodel.limit
      my_sub.word_follow=submodel.limit_follow
      my_sub.project=submodel.limit_project
      my_sub.subscription_model_id = submodel.id
      if my_sub.save
        return true
      else 
        return false
      end 
    end

  class << self
    # author:Noha hesham
    # Description:
    #   takes the developer id and integer type and checks wether 
    #   the developer's word search ,word add and word follow
    #   limit has been reached ,if its not then it is greater than zero 
    #   and permission is given by returning true else return false
    #   and permission denied.
    # params:
    #   developer id and type
    # success:
    #   permission is given if the developer didnt exceed the search ,add
    #   or follow limit
    # fail:
    #   none
      def get_permission_follow(dev_id)
        my_subscription = 
         MySubscription.joins(:developer).where(:developer_id => dev_id).first
          if @count < my_subscription.word_follow 
            return true
          else
            return false
          end
        end        
  # Author:
  #  Noha Hesham
  # Description:
  #  counts the number of the followed word by the
  #  developer till now
  # Success:
  #  gets the correct number of words counted
  # Failure:
  #  none 
   def count_follow
    @developer = Developer.find(self.developer_id)
    @count_follow=@developer.Keywords.count   
  end
  end
  # Author:
  #   Noha Hesham
  # Description:
  #   It compares the created projects with the developer's project
  #   limit and returns true if the developer didnt pass the limit
  # Success:
  #   Gives permission
  # Failure:
  #   None 
  def self.get_projects
    dev = Developer.find_by_gamer_id(current_gamer.id).id
    my_subscription = 
      MySubscription.joins(:developer).where(:developer_id => dev_id).first
      project = Project.where(:developer_id => owner_id)
      if project.count < my_subscription.project
        return true
      else
        return false
  end
  # Author:
  #   Noha Hesham
  # Description:
  #   It compares the words added by the developer to the add
  #   limit and returns true if the developer didnt pass the limit
  # Success:
  #   Gives permission to add words
  # Failure:
  #   None 
  def self.add_max_word
    dev = Developer.find_by_gamer_id(current_gamer.id).id
    my_subscription = 
      MySubscription.joins(:developer).where(:developer_id => dev_id).first
      project = Project.where(:developer_id => owner_id)
      add=PreferedSynonym.where(:project_id => project_id )
      if add.count < my_subscription.limit
        return true
      else
        return false
  end
  # Author:
  #   Noha Hesham
  # Description:
  #   It takes the word id and checks if the developer has searched for it before
  #   if no it checks if the developer has passed the search limit and 
  #   gives permission accordingly
  # Success:
  #   Gives permission to search
  # Failure:
  #   None 
  def self.get_max_words(word_id)
    dev_id = Developer.find_by_gamer_id(current_gamer.id).id
    my_subscription = 
      MySubscription.joins(:developer).where(:developer_id => dev_id).first
    word = Search.joins(:keyword).where(:keyword_id => word_id)
    if word!= nil
      return true
    else 
      if my_subscription.word_search > Search.where(:developer_id => dev_id).count 
         search=Search.new
         return true
       else
        return false 
       end 
    end
  end
end
