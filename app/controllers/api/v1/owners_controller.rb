class Api::V1::OwnersController < Api::BaseController

  skip_before_filter :verify_authenticity_token, :only => [:create, :destroy]

  before_filter :authenticate_with_api_key
  before_filter :verify_authenticated_user
  before_filter :find_rubygem
  before_filter :verify_gem_ownership

  respond_to :yaml, :xml, :json, :only => :show

  def show
    respond_with @rubygem.owners
  end

  def create
    if owner = User.find_by_email(params[:email])
      @rubygem.ownerships.create(:user => owner)
      render :text => 'Owner added successfully.'
    else
      render :text => 'Owner could not be found.', :status => :not_found
    end
  end

  def destroy
    if owner = @rubygem.owners.find_by_email(params[:email])
      if @rubygem.ownerships.find_by_user_id(owner.id).try(:destroy)
        render :text => "Owner removed successfully."
      else
        render :text => 'Unable to remove owner.', :status => :forbidden
      end
    else
      render :text => 'Owner could not be found.', :status => :not_found
    end
  end

protected

  def verify_gem_ownership
    unless current_user.rubygems.find_by_name(params[:rubygem_id])
      render :text => 'You do not have permission to manage this gem.', :status => :unauthorized
    end
  end

end
