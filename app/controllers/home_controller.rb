# coding: utf-8
class HomeController < ApplicationController
  include HomeHelper
  layout 'public'

  def index
    @branches = Branch.where.not(georeference: nil)
    @providers = Provider.all
    @common_info = CommonInfoService.call

    # dummy data
    @provider_a = Provider.all[0]
    @provider_b = Provider.all[1]
  end

  def about
  end

end
