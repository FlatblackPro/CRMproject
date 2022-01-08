package com.bjpowernode.crm.activity.service;

import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblActivityRemark;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface ActivityService {

    boolean saveActivity(TblActivity tblActivity);

    PaginationVO<TblActivity> getActivity(Map<String, Object> getActivityMap);

    boolean deleteActivity(String[] activityIds);

    Map<String, Object> editActivity(String id);

    Boolean editActivityUpdate(Map<String, Object> map);

    TblActivity detail(String activityId);

    List<TblActivityRemark> detailRemark(String activityId);

    boolean deleteRemark(String remarkId);

    Boolean saveRemark(TblActivityRemark tblActivityRemark);

    boolean editRemark(TblActivityRemark tblActivityRemark);

    List<TblActivity> showClueActivity(String clueId);

    List<TblActivity> convertSearchAndShow(String clueId, String activityName);

    List<TblActivity> getActivityByContact(String activityName, String contactId);
}
