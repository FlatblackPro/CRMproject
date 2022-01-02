package com.bjpowernode.crm.activity.service.Impl;

import com.bjpowernode.crm.activity.dao.ActivityDao;
import com.bjpowernode.crm.activity.dao.ActivityRemarkDao;
import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblActivityRemark;
import com.bjpowernode.crm.activity.service.ActivityService;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityServiceImpl implements ActivityService {
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);
    private UserDao userDao = SqlSessionUtil.getSqlSession().getMapper(UserDao.class);
    @Override
    //添加市场活动业务
    public boolean saveActivity(TblActivity tblActivity) {
        /*这里需要进行具体的业务操作：
        1. 调用dao，通过框架进行增加操作；
        2. 返回的值进行判断，1=true；其他=false；
         */
        boolean flag = true;
        int number = activityDao.saveActivity(tblActivity);
        if (number != 1){
            flag = false;
            return flag;
        }
        return flag;
    }

    @Override
    //市场活动的查询业务
    public PaginationVO<TblActivity> getActivity(Map<String, Object> getActivityMap) {
            /*
    这里主要分成两步操作：
    1. 调用DAO查询activity，返回一个List；
    2. 调用DAO查询total，返回一个total数量--int
     */
        //这里第一次调用DAO，获取LIST：
        List<TblActivity> tblActivityList = activityDao.getActivity(getActivityMap);
        //这里第二次调用DAO，获取total：
        int total = activityDao.getActivityCount(getActivityMap);
        PaginationVO<TblActivity> VO = new PaginationVO<>();
        VO.setDataList(tblActivityList);
        VO.setTotal(total);
        return VO;
    }

    @Override
    //市场活动删除业务
    public boolean deleteActivity(String[] activityIds) {
        //受到影响的所有的市场行动对应的备注数量
        int remarkCount;
        //删除的备注数量
        int deleteRemarkCount;
        //删除的市场活动
        int activityCount;
/*        这里的业务分为2块：
        1. 删除市场活动关联的备注信息（另一张表中）；
        2. 删除市场活动
        只有当备注信息被删除了，才能删除市场活动；只有当市场活动被删除了，才能返回true；*/
        //查询与活动相关的备注的数量：
        remarkCount = activityRemarkDao.getActivityRemark(activityIds);
        //先删除市场活动相关的备注信息：
        deleteRemarkCount = activityRemarkDao.deleteActivityRemark(activityIds);
        //当备注信息被删了(查找到的备注信息==已删除的备注信息)：
        if (remarkCount == deleteRemarkCount){
            //在此处进行市场活动的删除业务：
            activityCount = activityDao.deleteActivity(activityIds);
            //如果市场行动被删除了：
            //如果删除的数量==数组中id的数量，那么说明删除成功：
            if (activityCount == activityIds.length){
                return true;
            }
        }
        //程序走到这里，说明市场行动没有被删除：
        return false;
    }

    @Override
    //修改市场活动业务1（先查询信息，并在模态窗口中展示）
    public Map<String, Object> editActivity(String id) {
        //先通过userdao，拿到所有的user
        List<User> uList = userDao.getUserList();
        //通过activityDao，拿到针对某ID的活动的具体信息：
        TblActivity activity = activityDao.editActivity(id);
        Map<String, Object> map = new HashMap<>();
        map.put("uList", uList);
        map.put("activity", activity);
        return map;
    }

    @Override
    //修改市场活动业务2（在模态窗口中展示数据后，拿到更新的数据，update）
    public Boolean editActivityUpdate(Map<String, Object> map) {
        /*
        这里和save操作类似：
         */
        int number = activityDao.editActivityUpdate(map);
        if (number != 1){
            return false;
        }
        return true;
    }

    @Override
    //点击市场活动，跳转页面，展现市场活动详细信息：
    public TblActivity detail(String activityId) {
        //业务层只需要调用DAO，查找对象，然后返回给控制器即可：
        ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
        TblActivity tblActivity = activityDao.detail(activityId);
        return tblActivity;
    }

    @Override
    //在活动详细信息页展示备注信息（评论）：
    public List<TblActivityRemark> detailRemark(String activityId) {
        //在业务层，只需要调用DAO，通过ID找所有和其相关的内容即可：
        List<TblActivityRemark> tblActivityRemarks = activityRemarkDao.detailRemark(activityId);
        return tblActivityRemarks;
    }

    @Override
    //备注信息删除功能（评论）：
    public boolean deleteRemark(String remarkId) {
        boolean flag;
        flag = activityRemarkDao.deleteRemark(remarkId);
        return flag;
    }

    @Override
    //备注信息添加功能（评论）：
    public Boolean saveRemark(TblActivityRemark tblActivityRemark) {
        int flag = 0;
        flag = activityRemarkDao.saveRemark(tblActivityRemark);
        if (flag == 1){
            return true;
        }
        return false;
    }

    @Override
    //备注信息修改功能：
    public boolean editRemark(TblActivityRemark tblActivityRemark) {
        int num = activityRemarkDao.editRemark(tblActivityRemark);
        if (num == 1){
            return true;
        }else {
            return false;
        }
    }

    @Override
    //进入线索详细信息页后，展现关联该线索的市场活动：
    public List<TblActivity> showClueActivity(String clueId) {
        List<TblActivity> tblActivityList = activityDao.showClueActivity(clueId);
        return tblActivityList;
    }
}
