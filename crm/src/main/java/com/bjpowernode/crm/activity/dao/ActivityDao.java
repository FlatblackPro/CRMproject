package com.bjpowernode.crm.activity.dao;

import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblActivityRemark;
import com.bjpowernode.crm.settings.domain.User;

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

}