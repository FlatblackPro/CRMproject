package com.bjpowernode.crm.activity.domain;


public class TblContactsActivityRelation {

  private String id;
  private String contactsId;
  private String activityId;


  public String getId() {
    return id;
  }

  public void setId(String id) {
    this.id = id;
  }


  public String getContactsId() {
    return contactsId;
  }

  public void setContactsId(String contactsId) {
    this.contactsId = contactsId;
  }


  public String getActivityId() {
    return activityId;
  }

  public void setActivityId(String activityId) {
    this.activityId = activityId;
  }

}
