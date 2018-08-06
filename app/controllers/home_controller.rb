# coding: utf-8
class HomeController < ApplicationController
  before_action :check_for_mobile
  include HomeHelper

  def index
    @branches = Branch.where.not(georeference: nil)
    @common_info = CommonInfoService.call
  end

  def about
  end

end
