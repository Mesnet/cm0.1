class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  require 'will_paginate/array'


  def redirect_back(options = {})
    if request.referer
      redirect_to request.referer, options
    else
      redirect_to root_path, options
    end
  end

  protected

  def record_not_found
    redirect_to root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:pseudo, :name, :surname, :color, :registred, :company])
  end

  def enable_nav
    @enable_nav = true
  end

  def group_autorization
    @group = Group.find(params[:groupid])
    unless @group.cached_users.include?(current_user)
      respond_to do |format|
        redirect_to root_path
        # Vous ne faites pas parti de ce groupe
      end
    end
  end

  def have_company
    unless current_user.company?
      unless current_user.pseudo.present?
        respond_to do |format|
          format.html { redirect_to user_info_register_path }
          flash[:notice] = "Vous devez compléter votre profile" 
        end
      else 
        respond_to do |format|
          format.html { redirect_to new_company_path }
          flash[:notice] = "Vous devez créer votre entreprise" 
        end
      end
    end
  end
  
end
