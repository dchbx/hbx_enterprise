class CarriersController < ApplicationController
  def index
	  @carriers = Carrier.all

    respond_to do |format|
	    format.html # index.html.erb
	    format.json { render json: @carriers }
	  end
  end

  def show
		@carrier = Carrier.find(params[:id])
		@plans = @carrier.plans.ascending(:name, :hios_plan_id)

	  respond_to do |format|
		  format.html # index.html.erb
		  format.json { render json: @carrier }
		end
  end

  def show_plans
    @carrier = Carrier.find(params[:carrier_id])
    @plans = @carrier.plans.only(:name).ascending(:name, :hios_plan_id)

    render json: @plans
  end

  def calculate_premium
    plan = Plan.find(params[:Plans])
    rate_period_date = DateTime.strptime(params[:rate_period_date], '%m/%d/%Y')
    benefit_begin_date = DateTime.strptime(params[:benefit_begin_date], '%m/%d/%Y')
    birth_date = DateTime.strptime(params[:birth_date], '%m/%d/%Y')

    @rate = plan.rate(rate_period_date, benefit_begin_date, birth_date)
    
    respond_to do |format|
      format.js
    end
  end
end
