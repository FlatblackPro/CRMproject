package com.bjpowernode.crm.activity.service.Impl;

import com.bjpowernode.crm.activity.dao.*;
import com.bjpowernode.crm.activity.domain.*;
import com.bjpowernode.crm.activity.service.ClueService;
import com.bjpowernode.crm.settings.dao.UserDao;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.utils.DateTimeUtil;
import com.bjpowernode.crm.utils.SqlSessionUtil;
import com.bjpowernode.crm.utils.UUIDUtil;
import com.bjpowernode.crm.vo.PaginationVO;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ClueServiceImpl implements ClueService {
    //线索代理类3
    private ClueDao clueDao = SqlSessionUtil.getSqlSession().getMapper(ClueDao.class);
    private ClueRemarkDao clueRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ClueRemarkDao.class);
    private ClueActivityRelationDao clueActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ClueActivityRelationDao.class);
    //活动代理类2
    private ActivityDao activityDao = SqlSessionUtil.getSqlSession().getMapper(ActivityDao.class);
    private ActivityRemarkDao activityRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ActivityRemarkDao.class);
    //客户代理类2
    private CustomerDao customerDao = SqlSessionUtil.getSqlSession().getMapper(CustomerDao.class);
    private CustomerRemarkDao customerRemarkDao = SqlSessionUtil.getSqlSession().getMapper(CustomerRemarkDao.class);
    //客户联系人代理类3
    private ContactsActivityRelationDao contactsActivityRelationDao = SqlSessionUtil.getSqlSession().getMapper(ContactsActivityRelationDao.class);
    private ContactsDao contactsDao = SqlSessionUtil.getSqlSession().getMapper(ContactsDao.class);
    private ContactsRemarkDao contactsRemarkDao = SqlSessionUtil.getSqlSession().getMapper(ContactsRemarkDao.class);
    //交易代理类2
    private TranDao tranDao = SqlSessionUtil.getSqlSession().getMapper(TranDao.class);
    private TranHistoryDao tranHistoryDao = SqlSessionUtil.getSqlSession().getMapper(TranHistoryDao.class);



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

    @Override
    //核心功能：将线索转换为交易、或者客户联系人，然后删除这条线索。
    /**
     * (1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
     * (2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
     * (3) 通过线索对象提取联系人信息，保存联系人
     * (4) 线索备注转换到客户备注以及联系人备注
     * (5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
     * (6) 如果有创建交易需求，创建一条交易
     * (7) 如果创建了交易，则创建一条该交易下的交易历史
     * (8) 删除线索备注
     * (9) 删除线索和市场活动的关系
     * (10) 删除线索
     */
    public boolean clueConvert(String clueId, TblTran tran, String createBy) {
        /**--------------------------------------------------------------------------------------------
        * (1) 获取到线索id，通过线索id获取线索对象（线索对象当中封装了线索的信息）
        */
        TblClue clue = clueDao.getClueById(clueId);
        /**--------------------------------------------------------------------------------------------
         * (2) 通过线索对象提取客户信息，当该客户不存在的时候，新建客户（根据公司的名称精确匹配，判断该客户是否存在！）
         */
        String company = clue.getCompany();
        TblCustomer customer = customerDao.getCustomerByCompany(company);
        if (customer == null){
            //客户不存在，新建客户：
            customer = new TblCustomer();
            customer.setId(UUIDUtil.getUUID());
            customer.setOwner(clue.getOwner());
            customer.setName(company);
            customer.setWebsite(clue.getWebsite());
            customer.setPhone(clue.getPhone());
            customer.setCreateBy(createBy);
            customer.setCreateTime(DateTimeUtil.getSysTime());
            customer.setContactSummary(clue.getContactSummary());
            customer.setNextContactTime(clue.getNextContactTime());
            customer.setDescription(clue.getDescription());
            customer.setAddress(clue.getAddress());
            //将客户信息保存到数据库中：
            int flag1 = customerDao.saveCustomer(customer);
            if (flag1 != 1){
                return false;
            }
        }
        /**--------------------------------------------------------------------------------------------
         * (3) 通过线索对象提取联系人信息，保存联系人
         */
        TblContacts contacts = new TblContacts();
        contacts.setId(UUIDUtil.getUUID());
        contacts.setOwner(clue.getOwner());
        contacts.setCustomerId(customer.getId());
        contacts.setFullname(clue.getFullname());
        contacts.setAppellation(clue.getAppellation());
        contacts.setEmail(clue.getEmail());
        contacts.setMphone(clue.getMphone());
        contacts.setJob(clue.getJob());
        contacts.setBirth(null);
        contacts.setCreateBy(createBy);
        contacts.setCreateTime(clue.getCreateTime());
        contacts.setDescription(clue.getDescription());
        contacts.setContactSummary(clue.getContactSummary());
        contacts.setNextContactTime(clue.getNextContactTime());
        contacts.setAddress(clue.getAddress());
        contacts.setSource(clue.getSource());

        int flag2 = contactsDao.saveContacts(contacts);
        if (flag2 != 1){
            return false;
        }
        /**--------------------------------------------------------------------------------------------
         * (4) 线索备注转换到客户备注以及联系人备注
         */
        TblCustomerRemark customerRemark = null;
        //拿到线索备注的集合：
        List<TblClueRemark> clueRemarkList = clueRemarkDao.getClueRemarkByClueId(clueId);
        //线索转客户备注：
        for (TblClueRemark clueRemark:
             clueRemarkList) {
            customerRemark = new TblCustomerRemark();
            customerRemark.setId(UUIDUtil.getUUID());
            customerRemark.setNoteContent(clueRemark.getNoteContent());
            customerRemark.setCreateBy(createBy);
            customerRemark.setCreateTime(clue.getCreateTime());
            customerRemark.setCustomerId(customer.getId());
            customerRemark.setEditFlag("0");
            int flag3 = customerRemarkDao.saveCustomerRemark(customerRemark);
            if (flag3 != 1){
                return false;
            }
        }
        TblContactsRemark contactsRemark = null;
        //线索转客户备注：
        for (TblClueRemark clueRemark:
                clueRemarkList) {
            contactsRemark = new TblContactsRemark();
            contactsRemark.setId(UUIDUtil.getUUID());
            contactsRemark.setNoteContent(clueRemark.getNoteContent());
            contactsRemark.setCreateBy(createBy);
            contactsRemark.setCreateTime(clue.getCreateTime());
            contactsRemark.setContactsId(contacts.getId());
            contactsRemark.setEditFlag("0");
            int flag4 = contactsRemarkDao.saveContactsRemark(contactsRemark);
            if (flag4 != 1){
                return false;
            }
        }
        /**--------------------------------------------------------------------------------------------
         * (5) “线索和市场活动”的关系转换到“联系人和市场活动”的关系
         */
        TblContactsActivityRelation contactsActivityRelation = null;
        List<TblClueActivityRelation> clueActivityRelationList = clueActivityRelationDao.getActivityIdByClueId(clueId);
        for (TblClueActivityRelation clueActivityRelation:
             clueActivityRelationList) {
            contactsActivityRelation = new TblContactsActivityRelation();
            contactsActivityRelation.setId(UUIDUtil.getUUID());
            contactsActivityRelation.setActivityId(clueActivityRelation.getActivityId());
            contactsActivityRelation.setContactsId(contacts.getId());
            int flag5 = contactsActivityRelationDao.saveContactsActivityRelation(contactsActivityRelation);
            if (flag5 != 1){
                return false;
            }
        }
        /**--------------------------------------------------------------------------------------------
         * (6) 如果有创建交易需求，创建一条交易
         */
        if (tran != null){
            tran.setOwner(clue.getOwner());
            tran.setCustomerId(customer.getId());
            tran.setSource(clue.getSource());
            tran.setContactsId(contacts.getId());
            tran.setDescription(clue.getDescription());
            tran.setContactSummary(contacts.getContactSummary());
            tran.setNextContactTime(clue.getNextContactTime());
            int flag6 = tranDao.saveTran(tran);
            if (flag6 != 1){
                return false;
            }
            /**--------------------------------------------------------------------------------------------
             * (7) 如果创建了交易，则创建一条该交易下的交易历史
             */
            TblTranHistory tranHistory = new TblTranHistory();
            tranHistory.setId(UUIDUtil.getUUID());
            tranHistory.setCreateTime(tran.getCreateTime());
            tranHistory.setCreateBy(createBy);
            tranHistory.setTranId(tran.getId());
            tranHistory.setExpectedDate(tran.getExpectedDate());
            tranHistory.setMoney(tran.getMoney());
            tranHistory.setStage(tran.getStage());
            int flag7 = tranHistoryDao.saveTranHistory(tranHistory);
            if (flag7 != 1){
                return false;
            }
        }
        /**--------------------------------------------------------------------------------------------
         * (8) 删除线索备注
         */
        int flag8 = clueRemarkDao.deleteRemarkByClueId(clueId);
        if (flag8 == 0){
            return false;
        }
        /**--------------------------------------------------------------------------------------------
         * (9) 删除线索和市场活动的关系
         */
        int flag9 = clueActivityRelationDao.deleteClueActivityRelationByClueId(clueId);
        if (flag9 == 0){
            return false;
        }
        /**--------------------------------------------------------------------------------------------
         * (10) 删除线索
         */
        int flag10 = clueDao.deleteClueByClueId(clueId);
        if (flag10 == 0){
            return false;
        }
        return true;
    }
}
