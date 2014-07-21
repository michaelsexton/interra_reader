class IntierraReader
  
  def initialize(file) # make optional
    @csv = CSV.read(file)
	parse_csv
	parse_deposits
	#check_deposits

  end

  def parse_csv # Chuck in option args here
    parsed_csv = Hash.new
    data_block=Array.new
    @csv.each do |row| 
      first_column = row.first
      if !first_column.nil?
        case first_column
        when "CRITERIA FOR SEARCH RESULTS:"
          parsed_csv[:header] = Array.new
          data_block= parsed_csv[:header]
        when "ID"		  
          parsed_csv[:deposits] = Array.new
          data_block=parsed_csv[:deposits]
        when "Reserves/Resource"		  
          parsed_csv[:resources] = Array.new
          data_block=parsed_csv[:resources]
        when "Reserves/Resource Detail with Classification"
          parsed_csv[:classifications] =Array.new
          data_block=parsed_csv[:classifications]
        end
        data_block << row 
      end
    end
    @data =  parsed_csv
  end

  def parse_deposits # Chuck in option args here
    block = @data[:deposits]
    keys = [:id, :parent, :name, :propertyno, :latitude, :longitude, :status, :owner]
    indices=[0,1,2,3,4,6,8,9]
    key_pairs = keys.zip(indices)
    i=1  
    deposits = Array.new
    while (i < (block.size-1))
      row=block[i]
      deposits << Hash[key_pairs.map {|kp| [ kp[0] , row[kp[1]]] } ]
      i+=1
    end
	
    
	#deposits.map do |deposit|
	#	deposit[:ozmin]=check_deposit(deposit)
	#end
	
	@deposits = deposits
  end
  
  def check_deposits
  # What do we do here?
  # Loop through the array of deposits
  # For each deposit we check whether 
    flag = 0
	distance = 1 
	@deposits.each do |deposit|
	  while flag < 2
		ozmin deposits = spatially_locate_deposit(deposit, distance)
		if ozmin_deposits.count == 1
		  flag += 1
		end
		ozmin_depoists = check_name(ozmin_deposits, deposit)
	  end
	end
  end
  
  #change below to spatially_locate_deposit
  
  def spatially_locate_deposit (deposit, distance)
     puts "Testing #{deposit[:name]} ... With distance #{distance} km"
    if !deposit[:parent].nil?
      count = Deposit.distance(deposit[:longitude],deposit[:latitude],distance,'km').count
	  case 
	  when count < 1 
		ozmin_deposit = spatially_locate_deposit(deposit,distance*1.5)
	  when count > 1
	    ozmin_deposit = spatially_locate_deposit(deposit,distance*0.5)
	  when count == 1
	    ozmin_deposit = Deposit.distance(deposit[:longitude],deposit[:latitude],distance,'km').all
	  end
	end
	ozmin_deposit
  end
 
end