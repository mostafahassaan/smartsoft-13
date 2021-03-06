# encoding: UTF-8
class GamesController < ApplicationController
  before_filter :authenticate_gamer_or_guest!

  def game
  end

  # Author:
  # 	Kareem Ali
  # Description:
  # 	displayes the vote form for the gamer
  # params:
  # 	word: takes keyword name for which the synonym choices will be displayed
  # success:
  # 	retrieve the approved synonym list limited to 4 only choosen randomly 
  # 	if the approved synonyms for the keyword is more than 4, keyword 
  #   object and the keyword name
  # failure:
  # 	--------- 
  def vote
  	@word = params[:word]
  	@keyword = Keyword.where(name: @word).first
  	@synonym_list = @keyword.retrieve_synonyms()[0]
  	list_length = @synonym_list.length
  	while list_length > 4 do
        random_number = rand 0..list_length - 1
        @synonym_list.delete_at(random_number)
        list_length = @synonym_list.length
    end
    respond_to do |format|
      format.js
    end
  end
  
  # Author:
  # 	Kareem Ali
  # Description:
  # 	makes the action of saving the vote for the gamer
  # params:
  # 	synonym_id: takes the synonym id for which the gamer voted for
  #   is_formal: the formality of the synonym the gamer voted for
  # success:
  # 	passes the synonym_id to the record_vote view
  # failure:
  #  	---------
  def record_vote
    @is_formal = params[:is_formal]
    @synonym_id = params[:synonym_id]
    respond_to do |format|
      format.js
    end
  end 

  # Author:
  #   Amr Abdelraouf
  # Description:
  #   When called the method envokes the current gamer's 'getToken' to get 
  #   his/her facebook token and posts an invitation message on his/her row
  # Params:
  #   None
  # Success:
  #   User is connected, token is valid and the wall post is posted to the
  #   user's wall
  # Failure:
  #   The user is not connected: S/He's redirected to the settings page
  #   The user's token has expired: S/He will be redirected to the Facebook
  #   reauthentication page
  #   The user is trying to post more than once in a short period of time
  #   (facebook doesn't allow this to discourage spamming) a flash notice
  #   will appear explaining the situation
  #   The user is not signed in: S/He'll be redirected to the sign in page
  def post
    if current_gamer
      if !Authentication.is_connected_to_facebook(current_gamer.id)
        flash[:error] = t(:connect_your_account) 
        redirect_to "/gamers/edit"
      else
        begin
          if Authentication.exists?(gamer_id: current_gamer.id, provider: "facebook")
            token = Authentication.get_token(current_gamer.id, "facebook")
            @graph = Koala::Facebook::API.new(token)
            @graph.put_wall_post(
              "Checkout the new Arability game @ localhost:3000/game")
            flash[:success] = t(:shared_on_fb)
            redirect_to "/game"
          else
            flash[:error] = t(:you_need_to_connect_fb)
            redirect_to "/gamers/edit"
          end
        rescue Koala::Facebook::AuthenticationError
          redirect_to "/auth/facebook"
        rescue Koala::Facebook::ClientError
          flash[:notice] = t(:error_fb)
          redirect_to "/game"
        end
      end
    else
      flash[:error] = t(:sign_in_facebook)
      redirect_to "/gamers/sign_in"
    end
  end

  # Description:
  #   After the gamer finishes a level this action is requested
  #   to award them with their prizes if they have any
  # Author:
  #   Adam Ghanem
  # @params:
  #   level: the level that the gamer finishes
  #   score: the score that the gamer earns
  # returns:
  #   success: lists out the prizes the gamer wins in a js erb view
  #   failure: the action is not even called
  def get_prizes
    @level = params[:level].to_i
    @score = params[:score].to_i
    @won_prizes = Prize.get_new_prizes_for_gamer(current_gamer.id, 
                                                 @score, @level)
    respond_to do |format|
      format.js
    end
  end

  # Author:
  #   Omar Hossam
  # Description:
  #   As a gamer, I could post my score on my facebook timeline by pressing on
  #   the facebook share score button.
  # Parameters:
  #   score: a variable that saves gamer's score recieved from view.
  # Success:
  #   Gamer presses the facebook share score button, and his score is shared on
  #   facebook and confirmed by API.
  # Failure: 
  #   The user is not connected: S/He's redirected to the settings page
  #   The user's token has expired: S/He will be redirected to the Facebook
  #   reauthentication page
  #   The user is trying to post more than once in a short period of time
  #   (facebook doesn't allow this to discourage spamming) a flash notice
  #   will appear explaining the situation
  #   The user is not signed in: S/He'll be redirected to the sign in page
  def post_score_facebook
    score = params[:score]
    if current_gamer
      if !Authentication.is_connected_to_facebook(current_gamer.id)
        @message = t(:connect_your_account) 
        @redirect = "/gamers/edit"
      else
        begin
          if Authentication.exists?(gamer_id: current_gamer.id, provider: "facebook")
            token = Authentication.get_token(current_gamer.id, "facebook")
            @graph = Koala::Facebook::API.new(token)
            @graph.put_wall_post(
              t(:post_on_fb) + "#{score}" + t(:post_on_fb_2))
            @message = t(:posting_success)
          else
            @message = t(:you_need_to_connect_fb)
            @redirect =  "/gamers/edit"
          end
        rescue Koala::Facebook::AuthenticationError
          @redirect =  "/auth/facebook"
        rescue Koala::Facebook::ClientError
          @message = t(:error_fb)
        end
      end
    else
      flash[:error] = t(:sign_in_facebook)
      redirect_to =  "/gamers/sign_in"
    end
    render "messages.js"
  end

  # Description:
  #   After the gamer finishes a level this action is requested
  #   to award them with their trophies if they have any
  # Author:
  #   Adam Ghanem
  # @params:
  #   level: the level that the gamer finishes
  #   score: the score that the gamer earns
  # returns:
  #   success: lists out the trophies the gamer wins and a score in a rendered js erb view 
  #            and sets the new high score if the new score is higher than the older one
  #   failure: the doesn't win any trophies and only sees his score in a rendered js erb view
  def get_trophies
    @level = params[:level].to_i
    @score = params[:score].to_i
    @won_trophies = Trophy.get_new_trophies_for_gamer(current_gamer.id,
                                                      @score, @level)
    @won_prizes = Prize.get_new_prizes_for_gamer(current_gamer.id,
                                                 @score, @level)

    if @score > current_gamer.highest_score.to_i
      current_gamer.update_attributes!(highest_score: @score)
    end
    respond_to do |format|
      format.js
    end
  end

  # Description:
  #   after the gamer finishes a level
  #   they get a page exactly like the 
  #   one with the gettrophies but doesn't have 
  #   any trophies listed out and the only option he will
  #   have is to restart the game
  # Author:
  #   Adam Ghanem
  # @params:
  #   score: the score that the gamer earns
  # returns:
  #   success: shows the score of the gamer in 
  #   a new view with a restart game button
  #   failure: none
  def get_score_only
    @score = params[:score].to_i
    if @score > current_or_guest_gamer.highest_score.to_i
      current_or_guest_gamer.update_attributes!(:highest_score => @score)
    end
    respond_to do |format|
      format.js
    end
  end


  # Description:
  #   Returns the view that the gamer can view the prizes that 
  #   are available currently in the game and the prizes that they
  #   have already earned
  # Author:
  #   Adam Ghanem
  # @params:
  #   none
  # returns:
  #   success: renders out a view using js erb view with the 
  #   earned prizes in a list and the prizes that haven't been 
  #   earned in another
  def show_prizes
    @won_prizes = current_gamer.get_won_prizes
    @not_won_prizes = current_gamer.get_available_prizes
    respond_to do |format|
      format.js
    end
  end

  # Description:
  #   Returns the view that the gamer can view the trophies that 
  #   are available currently in the game and the trophies that they
  #   have already earned
  # Author:
  #   Adam Ghanem
  # @params:
  #   none
  # returns:
  #   success: renders out a view using js erb view with the 
  #   earned trophies in a list and the trophies that haven't been 
  #   earned in another
  def show_trophies
    @won_trophies = current_gamer.get_won_trophies
    @not_won_trophies = current_gamer.get_available_trophies
    respond_to do |format|
      format.js
    end
  end

  # Author:
  # 	Kareem Ali
  # Description:
  # 	makes the action of saving the suggested synonym by the gamer
  # params:
  # 	synonym_name: takes the synonym name the gamer suggested
  # 	keyword_id:	takes the keyword id for the which the synonym is suggested
  #   is_formal: which determines whether the synonym is formal or slang
  # success:
  # 	returns 0 for record_output which means saved suggestion and
  # 	the already_existing_synonym whould be nill as the synonym is not existing
  #  	in the database 
  # failure:
  # 	returns 1 which means the the synonym_name is blank 
  # 	returns 2 for record_output is already existing and 
  # 	the second return variable would be the synonym object already existing.  
  def record_synonym
    @is_formal = params[:is_formal]
    if @is_formal == "formal"
      formality = true
    elsif @is_formal == "slang"
      formality = false
    else
      formality = nil
    end
    @record_output = current_or_guest_gamer.suggest_synonym(params[:synonym_name], 
      params[:keyword_id], formality) 
  	@already_existing_synonym = Synonym.where(name: params[:synonym_name],
      keyword_id: params[:keyword_id]).first 
    respond_to do |format|
      format.js
    end
  end

  # Author:
  #   Ali El Zoheiry
  # Description:
  #   updates the value of the show_tutorial column to false
  # params:
  #   none
  # success:
  #   the value of the column is successfuly changed to false
  # failure:
  #   none
  def disableTutorial
    current_or_guest_gamer.update_attributes!(show_tutorial: false)
  end
  # Author: 
  #   Nourhan Zakaria
  # Description:
  #   This method calls get_vote on the current gamer to get
  #   all votes given by a given gamer
  # Params:
  #   it just needs the current gamer 
  # Success: 
  #   renders a js view of the gamer vote log showing either
  #   their votes histroy or no votes if he/she didn't vote yet
  # Failure: 
  #   --
  def showprofile
    @count, @vote_log = current_or_guest_gamer.get_votes
    respond_to do |format|
      format.js
    end
  end

  def fame
  end

  def main_hall_of_fame
    render "mainhall.js"
  end

  def facebook_hall_of_fame
    render "facebook.js"
  end

  def twitter_hall_of_fame
    render "twitter.js"
  end

end
