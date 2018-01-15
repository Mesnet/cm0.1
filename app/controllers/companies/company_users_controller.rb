class Companies::CompanyUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :administrator

  def create
    @email = (params[:company_user][:email]).rstrip
    if @email =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      @company_user = CompanyUser.where(email: @email, company: params[:company_id], invitation: true).first_or_create
      if @company_user.save
        respond_to do |format|
          format.js { render 'companies/js/create_invit' }
        end
      end
    end
  end

private

  def administrator
    @company = current_user.companies.find(params[:company_id])
    unless @company.cached_admins.include?(current_user)
      respond_to do |format|
        format.html notice: "n'êtes pas administrateur" 
        format.js {render inline: "location.reload();" }
      end
    end
  end

end