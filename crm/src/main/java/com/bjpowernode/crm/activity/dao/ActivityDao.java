package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblActivityRemark;
import com.bjpowernode.crm.settings.domain.User;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ActivityDao {
    //市场活动新增
    int saveActivity(TblActivity tblActivity);

    //市场活动异步刷新显示（查询+分页+展示）
    List<TblActivity> getActivity(Map<String, Object> getActivityMap);

    //市场活动查询
    int getActivityCount(Map<String, Object> getActivityMap);

    //市场活动删除
    int deleteActivity(String[] activityIds);

    //市场活动修改操作1
    TblActivity editActivity(String id);

    //市场活动修改操作2
    int editActivityUpdate(Map<String, Object> map);

    //点击市场活动，跳转到市场活动详细信息页面：
    TblActivity detail(String activityId);

    //进入线索详细信息页后，展现关联该线索的市场活动：
    List<TblActivity> showClueActivity(String clueId);

    //在线索详细信息页，点击关联，打开模态窗口，搜索需要关联的市场活动：
    List<TblActivity> getClueActivityRelation(Map<String, String> map);

    //点击转换按键，弹出转换的页面，通过活动名称搜索市场活动（仅搜索关联的市场活动）
    List<TblActivity> convertSearchAndShow(@Param("clueId") String clueId,
                                           @Param("activityName") String activityName);

    //在添加交易页面中，打开查找市场活动源的模态窗口，搜索相关的市场活动：
    List<TblActivity> getActivityByContact(@Param("activityName") String activityName,
                                           @Param("contactsId") String contactId);
}
