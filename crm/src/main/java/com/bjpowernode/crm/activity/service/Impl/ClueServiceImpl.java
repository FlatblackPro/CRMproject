package com.bjpowernode.crm.activity.service.Impl;

import com.bjpowernode.crm.activity.dao.ActivityDao;
import com.bjpowernode.crm.activity.dao.ClueActivityRelationDao;
import com.bjpowernode.crm.activity.dao.ClueDao;
import com.bjpowernode.crm.activity.domain.TblActivity;
import com.bjpowernode.crm.activity.domain.TblClue;
import com.bjpowernode.crm.activity.domain.TblClueActivityRelation;
import com.bjpowernode.crm.activity.service.ClueService;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ClueServiceImpl implements ClueService {
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private ClueActivityRelationDao clueActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    @Override
    //添加线索功能：
    public Boolean saveClue(TblClue clue) {
        int count;
        count = clueDao.saveClue(clue);
        if (count == 1){
            return true;
        }
        return false;
    }

    @Override
    //刷新已更新、添加、修改的线索：
    public PaginationVO<TblClue> getClue(Map<String, Object> map) {
        List<TblClue> clueList = clueDao.getClue(map);
        int total = clueDao.getClueTotal(map);
        PaginationVO<TblClue> vo = new PaginationVO<>();
        vo.setTotal(total);
        vo.setDataList(clueList);
        return vo;
    }

    @Override
    //点击线索，进入详细信息页面：
    public TblClue getDetail(String id) {
        TblClue tblClue = clueDao.getDetail(id);
        return tblClue;
    }

    @Override
    //在线索详细信息页，用于解除市场活动和线索的关联：
    public Boolean deleteClueActivityRelation(String relationId) {
        int count = 0;
        count = clueActivityRelationDao.deleteClueActivityRelation(relationId);
        if (count == 1){
            return true;
        }
        return false;
    }

    @Override
    //在线索详细信息页，点击关联，打开模态窗口，搜索需要关联的市场活动：
    public List<TblActivity> getClueActivityRelation(Map<String, String> map) {
        List<TblActivity> tblActivityList = activityDao.getClueActivityRelation(map);
        return tblActivityList;
    }


    @Override
    //在线索详细信息页，点击关联，打开模态窗口，关联市场活动
    public boolean saveClueActivityRelation(Map<String, Object> map) {
        String clueId = (String) map.get("clueId");
        String[] ids = (String[]) map.get("ids");
        for (String id:
             ids) {
            String relationId = UUIDUtil.getUUID();
            TblClueActivityRelation relation = new TblClueActivityRelation();
            relation.setActivityId(id);
            relation.setClueId(clueId);
            relation.setId(relationId);
            int count = clueActivityRelationDao.saveClueActivityRelation(relation);
            if (count != 1){
                return false;
            }
        }
        return true;
    }

    @Override
    //在线索详细信息页，点击转换按键，弹出转换的页面，并将相应的信息铺进去：
    public TblClue convert(String clueId) {

        TblClue clue = clueDao.getDetail(clueId);
        return clue;
    }

}
