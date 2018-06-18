# coding: utf-8
class HomeController < ApplicationController
  layout 'public'

  def index
    @branches = Branch.where.not(georeference: nil)
  end

  def about
  end

end
