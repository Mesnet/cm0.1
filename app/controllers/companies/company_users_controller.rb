class Companies::CompanyUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company

  def create
    if params[:company_user][:email] =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      @company_user = CompanyUser.where(email: params[:company_user][:email], company: params[:company_id], invitation: true).first_or_create
      if @company_user.save
        respond_to do |format|
          format.js { render 'companies/js/create_invit' }
        end
      end
    end
  end

private

  def set_company
    @company = current_user.companies.find(params[:company_id])
  end

end