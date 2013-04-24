#encoding: UTF-8
require "spec_helper"
require "request_helpers"
include RequestHelpers
include Warden::Test::Helpers

describe DeveloperController, :type => :controller do

    it "should redirect to project path if current gamer is already a developer" do
      d = create_logged_in_developer()
      sign_in(d.gamer)
      get :new
      response.should redirect_to projects_path
    end

    it "should create new developer and redirect to choose subscription model page if current gamer is not a developer" do
      g = create_logged_in_user()
      sign_in(g)
      sm = SubscriptionModel.new
      sm.name = "Free Trial"
      sm.limit_search = 20
      sm.limit_follow = 20
      sm.limit_project = 20
      sm.save
      get :new
      response.should redirect_to choose_sub_path
    end
end