# coding: utf-8
class HomeController < ApplicationController
  before_action :check_for_mobile
  include HomeHelper

  def index
    search_service = SearchService.call
    @all_branches = Branch.includes(:provider).where.not(:georeference => nil)
    @branches = search_service.search('*')
    @common_info = CommonInfoService.call
  end

  def about
  end

end
