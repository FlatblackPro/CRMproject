package com.bjpowernode.crm.activity.service;

import com.bjpowernode.crm.activity.domain.TblClue;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.List;
import java.util.Map;

public interface ClueService {

    Boolean saveClue(TblClue clue);


    PaginationVO<TblClue> getClue(Map<String, Object> map);
}
