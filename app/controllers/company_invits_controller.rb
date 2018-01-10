class CompanyInvitsController < ApplicationController
  def create
    if params[:company_invit][:email] =~ /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
      respond_to do |format|
        @user = User.where(email: params[:company_invit][:email]).first
        if @user == nil
          @user = User.create(email: params[:company_invit][:email])
        end
        @company = Company.where(id: params[:company_invit][:company_id]).first
        if @company.cached_admins.include?(current_user)
          @company.company_users.where(user: @user, invitation: true).first_or_create
        end
        format.js { render 'companies/js/create_invit' }
      end
    end
  end
end
