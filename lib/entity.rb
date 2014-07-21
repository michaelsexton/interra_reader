class Entity < ActiveRecord::Base
  self.abstract_class = true

  self.table_name = "a.entities"
  self.primary_key = :eno

  set_date_columns :entrydate, :qadate, :lastupdate, :effective_date, :acquisition_date, :expiry_date
  ignore_table_columns :confid_until

  has_many :entity_attributes, :class_name => "EntityAttribute",  :foreign_key => :eno

  scope :bounds, lambda { |bbox| { :conditions => bounds_conditions(bbox) } }
  
  
  # XXX Required due to bad data in the confid_until field
  def self.default_scope
    self.where(:confid_until=>nil)
  end 

  def name
    entityid
  end

  def latitude
    if geom?
      return geom.as_georuby.y
    end
  end

  def longitude
    if geom?
      return geom.as_georuby.x
    end
  end

  def self.bounds_conditions (bounds)
    #bounds=eval(bounds) # the params hash is a string of an array, ie "[x0,y0,x1,y1]", needs to be converted - probably should do it in the controller
    bbox = GeoRuby::SimpleFeatures::Polygon.from_coordinates(bounds.as_coordinates, 4326 )
    return geom_conditions(bbox)
  end

  def self.geom_conditions(g)
    conditions = ["SDO_ANYINTERACT(#{table_name}.geom, #{g.as_sdo_geometry}) = 'TRUE'"]
    return conditions
  end
 
  def self.distance(lon, lat, distance, units)
    geometry = "SDO_GEOMETRY(3001, 8311, SDO_POINT_TYPE(#{lon},#{lat},NULL), NULL, NULL)"
    where("SDO_WITHIN_DISTANCE(#{table_name}.geom,#{geometry},'distance=#{distance} units=#{units}') ='TRUE'")
  end 
  
  # TODO Probably should pass object, check whether object is of type Entity, then use that Entity's id.
  def self.intersect(id)
    where("SDO_ANYINTERACT(#{table_name}.geom, (select geom from a.entities where eno = #{id})) = 'TRUE'")
  end

  def self.not_a_polygon
    where('entities.get_gtype() <> 3007')
  end
  
  # Change to match other methods
  scope :by_name, lambda { |name| { :conditions=> ["UPPER(a.entities.entityid) like UPPER(:name)",{:name=> "%#{name}%"}] } }
  
  def quality_checked?
    return qa_status_code == "C"
  end

  def qaed?
    return quality_checked?
  end

  def qa_record(date,user)
    self.qadate=date
    self.qaby=user
    self.qa_status_code='C'
    self.save
  end
  
end
