class HouseholdController < ApplicationController

  def index
    @households = Household.all
    if params[:ajax]
      render partial: 'search'
    end
  end

  def create
    @household = Household.new
    @household.address = Address.new(address_params)
    @household.save
    if @household.valid? and @household.errors.empty?
      if params[:redirect_to_url]
        format.html {redirect_to params[:redirect_to_url]}
      else
        format.html { redirect_to @household, notice: 'Household was successfully updated.' }
        format.json { render action: 'show', status: :created, location: @household }
      end
    else
      format.html { render action: 'new' }
      format.json { render json: @household.errors, status: :unprocessable_entity }
    end
  end

  def show
    @household = Household.find(params[:id])
    @all_states = State.all
    respond_to do |format|
      format.html {
        if params[:ajax]
          render :partial => 'show', person_select: true
        else
          render 'show'
        end
      }
      #format.json { render action: 'show.json' }
    end
  end

  def edit
    @household = Household.find(params[:id])
    @all_states = State.all
    respond_to do |format|
      format.html {
        if params[:ajax]
          render :partial => 'edit'
        else
          render 'edit'
        end
      }
    end
  end

  def new
    @household = Household.new
    @household.address = Address.new
    @household.address.state = State.first
    @all_states = State.all
    respond_to do |format|
      format.html {
        if params[:ajax]
          render :partial => 'new'
        else
          render 'new'
        end
      }
      #format.json { render action: 'new.json' }
    end
  end

  # Used for selecting a household and associating it with a person
  def select
    @households = Household.all
    if params[:ajax]
      render partial: 'select'
    end
  end

  def search
    wild_card_query_fields = %w(people.firstname people.lastname)
    sql_params = []
    sql_where = ''

    if (params[:search])

      rowlimit = params[:rowlimit] || 10
      search_keys = JSON.parse(params[:search]).to_a

      wild_card_query_fields.each do |field|
        search_keys.each do |key|
          sql_where += ' OR ' if sql_where != ''
          sql_where += "#{field} LIKE ?"
          sql_params.push("#{key}%")
        end
      end

      @households = Household.joins(:person).where(sql_where, *sql_params).order('people.lastname').first(rowlimit.to_i)

    else
      @households = Household.all
    end
    #@people = Person.where("firstname LIKE ? #{sql_conditional} lastname LIKE ?", firstname_key, lastname_key).first(rowlimit.to_i)
    @new_household = Household.new
    respond_to do |format|
      format.html {
        if params[:ajax]
          render :partial => 'search_results'
        else
          render action: 'index'
        end
      }
      format.json { render action: 'index.json' }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def address_params
    params.require(:address).permit(:line1, :line2, :city, :state, :zip, :state_id)
  end
end
