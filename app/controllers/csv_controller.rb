require 'rails/all'
require 'csv'

class CsvController < ApplicationController
  def import
    if params[:file] != nil then
      if params[:file].original_filename == "dataset_50.csv" then
        Dataset.import(params[:file])
      elsif params[:file].original_filename == "house_data.csv" then
        HouseDatum.import(params[:file])
      end
    end
  end

  def index
    @house_data = HouseDatum.all
    @dataset = Dataset.all

    # sqlでデータを集計
    # City別エネルギー生産量
    sql = '
            SELECT
              City, count(*) as count
            FROM
              house_data
            GROUP BY
              City
          '
    city_house_count = ActiveRecord::Base.connection.select_all(sql).to_hash
    city_house_count.each do |data|
      @london_housese = data["count"] if data["City"] == "London"
      @cambrige_housese = data["count"] if data["City"] == "Cambridge"
      @oxford_housese = data["count"] if data["City"] == "Oxford"
    end

    sql = '
            SELECT
              City, SUM(EnergyProduction) as EnergyProduction
            FROM
              datasets
            INNER JOIN
              house_data
              ON datasets.House = house_data.ID
            GROUP BY
              City
          '
    city_energy = ActiveRecord::Base.connection.select_all(sql).to_hash

    city_energy.each do |data|
      @London = data["EnergyProduction"] if data["City"] == 'London'
      @Cambridge = data["EnergyProduction"] if data["City"] == 'Cambridge'
      @Oxford = data["EnergyProduction"] if data["City"] == 'Oxford'
    end

    # エネルギー生産量
    sql = '
            SELECT
              Year, Month, SUM(EnergyProduction) as EnergyProduction, City
            FROM
              datasets
            INNER JOIN
              house_data
              ON datasets.House = house_data.ID
            GROUP BY
              Year, Month, City
          '
    sql_result = ActiveRecord::Base.connection.select_all(sql).rows
    @lodon_year_energy = []
    @cambridge_year_energy = []
    @oxford_year_energy = []
    sql_result.each do |data|
      if data[3] == "London" then
        @lodon_year_energy.push [data[0], data[1], data[2]]
      elsif data[3] == "Cambridge" then
        @cambridge_year_energy.push [data[0], data[1], data[2]]
      elsif data[3] == "Oxford" then
        @oxford_year_energy.push [data[0], data[1], data[2]]
      end
    end
  end
end
