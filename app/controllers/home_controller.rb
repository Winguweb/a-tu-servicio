# coding: utf-8
class HomeController < ApplicationController
  before_action :check_for_mobile
  include HomeHelper
  include Reporting::Streamable
  include UserSessionator

  def show;end

  def services
    search_service = SearchService.call
    @all_branches = Branch.includes(:provider).where.not(georeference: nil).where(providers: { show: true })
    @common_info = CommonInfoService.call
  end

  def about;end

  def datasets
    @models = ["Branch","Provider","Satisfaction","Speciality","WaitingTime","Survey"]
  end

  def download_csv

    if params[:model].present?
      exporter_options = {
        model_klass: params[:model].singularize.classify.constantize,
      }
      reporter = "Reporting::#{params[:model]}Exporter".singularize.classify.constantize
      stream_csv(reporter, logged_in?, **exporter_options )
    end
  end

  def download_xlsx

    if params[:model].present?
      exporter_options = {
        model_klass: params[:model].singularize.classify.constantize,
      }
      reporter = "Reporting::#{params[:model]}Exporter".singularize.classify.constantize
      stream_xlsx(reporter, logged_in?, **exporter_options )
    end
  end

  def download_all
    send_file(
      "#{Rails.root}/public/download/unified_data.xlsx",
      filename: "unified_data.xlsx",
      type: "application/vnd.ms-excel"
    )
  end
end
