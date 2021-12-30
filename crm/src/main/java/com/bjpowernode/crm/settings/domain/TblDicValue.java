package com.bjpowernode.crm.settings.domain;


public class TblDicValue {

  private String id;
  private String value;
  private String text;
  private String orderNo;
  private String typeCode;

  public TblDicValue() {
  }

  public TblDicValue(String id, String value, String text, String orderNo, String typeCode) {
    this.id = id;
    this.value = value;
    this.text = text;
    this.orderNo = orderNo;
    this.typeCode = typeCode;
  }

  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }


  public String getValue() {
    return value;
  }

  public void setValue(String value) {
    this.value = value;
  }


  public String getText() {
    return text;
  }

  public void setText(String text) {
    this.text = text;
  }


  public String getOrderNo() {
    return orderNo;
  }

  public void setOrderNo(String orderNo) {
    this.orderNo = orderNo;
  }


  public String getTypeCode() {
    return typeCode;
  }

  public void setTypeCode(String typeCode) {
    this.typeCode = typeCode;
  }

}
