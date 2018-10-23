# coding: utf-8
class HomeController < ApplicationController
  before_action :check_for_mobile
  include HomeHelper
  include Reporting::Streamable


  def show;end

  def services
    search_service = SearchService.call
    @all_branches = Branch.includes(:provider).where.not(georeference: nil).where(providers: { show: true })
    @common_info = CommonInfoService.call
  end

  def about;end

  def download
    if params[:model].present?
      exporter_options = {
        data: params[:model].singularize.classify.constantize.all ,
      }
      reporter = "Reporting::#{params[:model]}Exporter".singularize.classify.constantize
      stream_csv(reporter, **exporter_options )
    end
  end
end