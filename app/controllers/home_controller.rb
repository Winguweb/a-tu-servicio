# coding: utf-8
class HomeController < ApplicationController
  include HomeHelper
  layout 'public'

  def index
    @branches = Branch.where.not(georeference: nil)
    # @providers = Provider.all
    @common_info = CommonInfoService.call

    # dummy data
    @branch_a = Branch.all[0]
    @branch_b = Branch.all[1]
  end

  def about
  end

end
