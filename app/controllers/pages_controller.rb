class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:home, :test]
  before_action :enable_nav, only: [:home, :test]
  before_action :have_company, except: [:landing]

  def home
  end

  def test
  end

  def landing
  end

  def show_invit
    respond_to do |format|
      format.js { render 'pages/invit/show' }
    end
  end
  
  private 

  def enable_nav
    @enable_nav = true
  end

end
