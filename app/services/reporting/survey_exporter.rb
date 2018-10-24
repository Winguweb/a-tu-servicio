module Reporting
  class SurveyExporter < Exporter

    include HomeHelper
    HEADER =  ["¿Qué tipo de usuario eres?", "Selecciona el servicio para el cual solicitaste la cita", "¿Cuánto tiempo pasó desde la asignación de la cita hasta que te atendieron?", "¿Cómo calificas la atención recibida?","Urgencias", "servicio de salud", "Evaluacion de personal"]
    #HEADER =  ["¿Qué tipo de usuario eres?", "Selecciona el servicio para el cual solicitaste la cita", "¿Cuánto tiempo pasó desde la asignación de la cita hasta que te atendieron?", "¿Cómo calificas la atención recibida?", "¿Cómo calificas tu experiencia en el servicio de urgencia?", "¿Qué valoras de tu experiencia en el servicio de urgencia?", "¿Qué valoras de tu experiencia en el servicio de urgencia?", "Escoja el personal por el cual fue atendido", "¿Cómo califica el trato del personal que lo atendio?", "¿Qué valoras de la atención recibida?", "¿Qué valoras de la atención recibida?", "¿Cuál es su nivel de satisfacción con la calidad el servicio de salud?", "¿Qué valoras de la calidad del servicio de salud?", "¿Qué valoras de la calidad del servicio de salud?"]
    # HEADER = Survey.all.pluck(:question_value).uniq.freeze

    def initialize(user,options = {})
      @surveys = options[:data]
      @user = user

    end

    def filename
      "surveys_#{Time.now.strftime('%Y-%m-%d')}"
    end

    def sheetname
      "surveys"
    end

    def csv_stream
      Enumerator.new do |result|
        result << csv_header

        yielder do |row|
          result << csv_row(row)
        end
      end
    end

    def data_stream
      Enumerator.new do |result|
        result << header

        yielder do |row|
          result << row
        end
      end
    end

    private

    def header
      @header ||= HEADER
    end


    def csv_header
      CSV::Row.new(header, header, true).to_s
    end

    def csv_row(values)
      CSV::Row.new(header, values).to_s
    end

    def yielder
      get_clients_id(@surveys).each do |client|
        yield row_data(client[0],client[1])
      end
    end

    def row_data(client,branch)
      group_answer_by_client(client,branch)
    end

    def get_clients_id(surveys)
      surveys.pluck(:client_id, :branch_id).uniq
    end

    
    def group_answer_by_client(client_id,branch_id)
      answers = []
      filter_data = Survey.where(client_id: client_id, branch_id: branch_id).pluck(:answer_data, :question_value,:step_id)#.uniq{ |ans| ans[1]}
    
      personal_data = []
      urgency_data = []
      service_data = []
      filter_data.each_with_index { |answer,index| 

        if answer[2] ==  11 #"Escoja el personal por el cual fue atendido"
          json = Hash.new
          json[answer[1]] = get_others_value(answer[0]) 
          json[filter_data[index +1][1]] =  get_others_value( filter_data[index +1][0])
          json[filter_data[index +2][1]] = get_others_value(filter_data[index +2][0])
          personal_data << json
        elsif answer[2] == 8 # "¿Cómo calificas tu experiencia en el servicio de urgencia?" 
          urgency_json = Hash.new
          urgency_json[answer[1]] = get_others_value(answer[0]) 
          urgency_json[filter_data[index +1][1]] =  get_others_value(filter_data[index +1][0])
          urgency_data << urgency_json
          answers << urgency_data
        elsif answer[2] == 15 #"¿Cuál es su nivel de satisfacción con la calidad el servicio de salud?"
         
          service_json = Hash.new
          service_json[answer[1]] = get_others_value(answer[0]) 
          service_json[filter_data[index +1][1]] = get_others_value(filter_data[index +1][0])
          service_data << service_json
        
          answers<< service_data
        elsif  ["¿Qué valoras de tu experiencia en el servicio de urgencia?" , "¿Cuál fue el motivo de tu mala experiencia?","¿Qué valoras de tu experiencia en el servicio de urgencia?", "¿Cómo califica el trato del personal que lo atendio?", "¿Qué valoras de la atención recibida?"].include?(answer[1]) || [13,21,16,17,24,23].include?(answer[2]) 
          next
        else
          answers << get_others_value(answer[0]) 
        end
         
      }
      answers << personal_data
      answers.uniq
      
    end

    def get_others_value(answer)
      return answer["label"] if !@user || !["Otro", "Otros"].include?(answer["label"]) 
      answer["value"]
    end


  end
end
