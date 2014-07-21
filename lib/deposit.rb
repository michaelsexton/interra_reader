class Deposit < Entity

  def self.default_scope
    where(:entity_type => 'MINERAL DEPOSIT')
  end

  has_one :deposit_status, :class_name => "DepositStatus", :foreign_key => :eno

  has_one :commodity_list, :class_name => "CommodityList",  :foreign_key => :idno

  has_many :zones, :class_name => "Zone",  :foreign_key => :parent

  has_many :resources, :through => :zones
  has_many :resource_grades, :through => :resources

  has_many :commodities, :class_name => "Commodity",  :foreign_key => :eno

  has_many :deposit_attributes, :class_name => "DepositAttribute",  :foreign_key => :eno

  # Replace below with Companies
  
  has_many :weblinks, :class_name => "Weblink", :foreign_key => :eno
  has_many :websites, :through => :weblinks, :class_name => "Website", :foreign_key => :websiteno
	
  def self.mineral(mineral)
    self.includes(:commodities).merge(Commodity.mineral(mineral))
  end

  def self.state(state)
    self.includes(:deposit_status).merge(DepositStatus.state(state))
  end

  def self.status(status)
    self.includes(:deposit_status).merge(DepositStatus.status(status))
  end
  
  def self.by_name(name)
    return self.joins(:deposit_status).where("upper (entityid) like upper('%#{name}%') or upper(synonyms) like upper('%#{name}%')")
  end
	
  scope :major, :include=>:commodities, :conditions=> "commorder < 10"
  scope :minor, :include=>:commodities, :conditions=> "commorder >= 9"

  scope :public, :include=>:commodities, :conditions=> "a.entities.access_code = 'O' and a.entities.qa_status_code = 'C'"

  def regname
    return deposit_attributes.regname.first.try(:valuename)
  end

  def minage_gp
    return deposit_attributes.minage_gp.first.try(:valuename)
  end

  def minsys_gp
    return deposit_attributes.minsys_gp.first.try(:valuename)
  end

  def minsys_sgp
    return deposit_attributes.minsys_sgp.first.try(:valuename)
  end

  def minsys_typ
    return deposit_attributes.minsys_typ.first.try(:valuename)
  end

  def classification
    return deposit_attributes.classification.first.try(:valuename)
  end

  def deposit_type
    return deposit_attributes.deposit_type.first.try(:valuename)
  end

  def atlas_visible?
    return quality_checked? && open_access? && geom?
  end

  def atlas_status?
    deposit_status.atlas_status?
  end


  def open_access?
    return access_code == "O"
  end

  def confidential?
    return access_code == "C"
  end

  def to_param
    "#{eno}-#{entityid.parameterize}"
  end 
  
end
