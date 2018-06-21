# coding: utf-8
class HomeController < ApplicationController
  include HomeHelper
  layout 'public'

  def index
    @branches = Branch.where.not(georeference: nil)
    @common_info = CommonInfoService.call
  end

  def about
  end

end
