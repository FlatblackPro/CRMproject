package com.bjpowernode.crm.activity.service.Impl;

import com.bjpowernode.crm.activity.dao.ClueDao;
import com.bjpowernode.crm.activity.domain.TblClue;
import com.bjpowernode.crm.activity.service.ClueService;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ClueServiceImpl implements ClueService {
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
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


}
