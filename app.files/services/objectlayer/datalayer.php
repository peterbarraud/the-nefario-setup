<?php

final class UserFactory
{
    /**
     * Call this method to get singleton
     *
     * @return UserFactory
     */
    public static function Instance()
    {
        static $inst = null;
        if ($inst === null) {
            $inst = new UserFactory();
        }
        return $inst;
    }

    /**
     * Private ctor so nobody else can instance it
     *
     */
    private function __construct()
    {
      $this->conn = new mysqli('localhost','peterb','Pokerj#07','tanikae1_meds');
    }
}

final class DataLayer {
  public static function Instance()
  {
      static $inst = null;
      if ($inst === null) {
          $inst = new DataLayer();
      }
      return $inst;
  }

  /**
    * Private ctor so nobody else can instance it
    *
    */
  private function __construct()
  {
    $this->conn = new mysqli('localhost:3800','pokerj','Pokerj#07','test_db');
  }

  public function __destruct()
  {
    $this->conn->Close();
  }
  
  //get all the fields for an object
  public function GetObjectData($object){
    if (!isset($object->id)){
      $object->id = 'null';
    }
    $sql_statement = 'select * from ' . get_class($object) . ' where id = ' . $object->id;
    $result = $this->conn->query($sql_statement);
    $row = $result->fetch_assoc();
    while ($fieldinfo = $result->fetch_field()) {
      $object->{$fieldinfo->name} = $row[$fieldinfo->name];
    }
  }

  public function GetProductObjectDataByKeyword($product, $keyword){
    $sql_statement = 'select * from product where keyword = "' . $keyword . '"';
    $result = $this->conn->query($sql_statement);
    $row = $result->fetch_assoc();
    while ($fieldinfo = $result->fetch_field()) {
      $product->{$fieldinfo->name} = $row[$fieldinfo->name];
    }
  }
  
  public function GetIdByFieldName($classname, $fieldname, $fieldvalue){
    $retval = null;
    // escape single quotes in field value
    $fieldvalue = str_replace('\'', '\\\'', $fieldvalue);
    $sql_statement = "select id from $classname where $fieldname = '$fieldvalue'";
    $result = $this->conn->query($sql_statement);
    while($row = $result->fetch_assoc()) {
      $retval = $row['id'];
    }
    return $retval;
  }

  public function GetKeywords(){
    $retval = array();
    $sql_statement = "select keyword from product";
    $result = $this->conn->query($sql_statement);
    while($row = $result->fetch_assoc()) {
      array_push($retval, $row['keyword']);
    }
    return $retval;

  }
  
  // many-to-many relations
  // deprecated
  // public function GetRelatedIdsByProductId($productid, $relatedtable){
  //   $retval = array();
  //   $sql_statement = "select " . $relatedtable . "id from product" . $relatedtable . " where productid = ";
  //   if ($productid == null){
  //     $sql_statement .= 'null';
  //   }
  //   else {
  //     $sql_statement .= $productid;
  //   }
  //   $result = $this->conn->query($sql_statement);
  //   while($row = $result->fetch_assoc()) {
  //     array_push($retval, $row[$relatedtable . 'id']);
  //   }
  //   return $retval;
  // }
  // deprecated
  // public function SaveRelatedProductObject($productid, $relatedtable, $relatedid){
  //   // right now what we're going to do is if the relationship exists we're just going to leave it alone
  //   $relatedidfield = str_replace('product', '', $relatedtable) . 'id';
  //   $sql_statement = "select count(id) as countid from $relatedtable where productid = $productid and $relatedidfield = $relatedid";
  //   $result = $this->conn->query($sql_statement);
  //   $record = $result->fetch_array(); 
  //   if (!$record[0]){
  //     $sql_statement = "insert into $relatedtable (productid, $relatedidfield) values ($productid, $relatedid);";
  //     $result = $this->conn->query($sql_statement);
  //   }    
  // }
  
  public function GetObjectIds($classname, $filter=null, $sortby=null, $sortdirection=null){
    $retval = array();
    $sql_statement = "select id from $classname";
    if ($filter != null){
      $sql_statement .= ' where';
      foreach ($filter as $fieldname => $fieldvalue){
        $sql_statement .= " $fieldname = '$fieldvalue' and";
      }
    }
    $sql_statement = rtrim($sql_statement,'and');
    if ($sortby !== null) {
      $sql_statement .= " order by $sortby $sortdirection";
    }
    $result = $this->conn->query($sql_statement);
    while($row = $result->fetch_assoc()) {
      array_push($retval, $row['id']);
    }
    return $retval;
  }

  public function Save($object, $override_duplicate=FALSE){
    if ($override_duplicate){
      // check if a record with this "name" exists
      $sql_statement = 'select id from ' . get_class($object) . ' where name = "' . $object->name . '";';
      $result = $this->conn->query($sql_statement);
      $record = $result->fetch_array();
      if ($record[0]){
        $object->id = $record[0];
      }    
    }
    //   insert if object id is null
      if ($object->id == null){
        $field_list = '';
        $value_list = '';
        foreach($object as $field => $value) {
          if ($field != 'id'){
            $field_list .= $field . ', ';
            $value_list .= '"' . $value . '", ';
          }
        }
        $field_list = rtrim(rtrim($field_list),',');
        $value_list = rtrim(rtrim($value_list),',');
        $execute_sql = 'insert into ' . get_class($object) . '(' . $field_list . ') values (' . $value_list . ');';
        $this->conn->query($execute_sql);
        $object->id = $this->conn->insert_id;
      }
    // else update
      else {
		  $set_list = '';
		  foreach($object as $field => $value) {
			  if ($field != 'id'){
				  if (isset($value)){
					  $value = '"' . $value . '"';
				  }
				  else {
					  $value = '""';					  
				  }
				  $set_list .= $field . ' = ' . $value . ', ';
			  }
		  }
		  $set_list = rtrim(rtrim($set_list),',');
		  $execute_sql = 'update ' . get_class($object) . ' set ' . $set_list . ' where id = ' . $object->id;
		  $this->conn->query($execute_sql);
      }

  }
  public function Delete($object)
  {
    // TODO
    // for now we're going to simply delete but we need to put in code to check if this component is being used
    // or should we have a isUsed function (property) for an object?
    // a check is not required since the foreign key constraint will stop this delete from happening
    // however, it would be a good idea to send back info to the user that the delete will not happend
    $execute_sql = 'delete from ' . get_class($object) . ' where id = ' . $object->id;
    $this->conn->query($execute_sql);
    return $this->conn->affected_rows;
  }
  public function DeleteProductParentData($object, $parenttable){
    $execute_sql = 'delete from ' . $parenttable . ' where productid = ' . $object->id;
    $this->conn->query($execute_sql);
    
  }
  // public function GetParentProductIDs($object){
  //   $productids = array();
  //   $execute_sql = 'select id from product where ' . get_class($object) . 'id = ' . $object->id;
  //   $result = $this->conn->query($execute_sql);
  //   while($row = $result->fetch_assoc()) {
  //     array_push($productids, $row['id']);
  //   }
  //   return $productids;
  // }
  
}
    

?>