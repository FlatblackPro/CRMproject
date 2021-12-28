package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblActivityRemark;

import java.util.List;

public interface ActivityRemarkDao {

    int getActivityRemark(String[] activityIds);

    int deleteActivityRemark(String[] activityIds);

    List<TblActivityRemark> detailRemark(String activityId);

    boolean deleteRemark(String remarkId);

    int saveRemark(TblActivityRemark tblActivityRemark);

    int editRemark(TblActivityRemark tblActivityRemark);
}
