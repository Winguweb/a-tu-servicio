# coding: utf-8
class HomeController < ApplicationController
  include HomeHelper
  layout 'public'

  def index
    @common_info = CommonInfoService.call
  end

  def about
  end

end
