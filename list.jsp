<%@page import="utils.DateUtils"%>
<%@page import="vo.Board"%>
<%@page import="java.util.List"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="dto.Pagination"%>
<%@page import="dao.BoardDao"%>
<%@page import="utils.NumberUtils"%>
<%@page import="dto.LoginUser"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<title>커뮤니티::게시글 목록</title>
</head>
<body>
<jsp:include page="../include/navbar.jsp">
	<jsp:param value="board" name="menu"/>
</jsp:include>

<div class="container">
	<div class="row">
		<div class="col=12">
			<h1>게시글 목록</h1>
			
<%
	//HttpSession에 LOGIN_USER 속성명으로 저장된 로그인된 사용자 정보 조회하기
	LoginUser loginUser = (LoginUser) session.getAttribute("LOGIN_USER");

	/*
		요청 URL
			localhost/comm/board/list.jsp
			localhost/comm/board/list.jsp?page =xx
			localhost/comm/board/list.jsp?opt=xxx&keyword=xxx
			localhost/comm/board/list.jsp?page=xxx & opt=xxx&keyword=xxx
		요청 파라미터
			page=xx
			opt=xx
			keyword=xx
			* 요청파라미터 page, opt, keyword는 있을 수도 있고, 없을수도 있다.
			* page는 조회했을 떄 null이거나 숫자가 조회된다..
				* null 일 때는 내비바의 메뉴를 클릭했을 떄다.
					comm/board/list.jsp
			* opt와 keyword는 조회했을 때 null ,빈문자열, 문자열이 조회된다.
				* null 일 때는 내비바의 메뉴를 클릭 했을 떄다
					comm/board/ list.jsp
				* 빈 문자열일 떄는 게시글목록페이지ㅔㅇ서 검색ㅇ벗이 단순히 페이지번호만 클릭했을 때
					comm/board/list.jsp?page=2&opt=&keyword=
				* 값이 있을 때는 옵션과 검색어를 입력하고 검색버튼을 클릭했을 때다.
					comm/board/list.jsp?page=1&opt=title&keyword=연습
				* 값이 있을 떄는 검색된 목록페이지에서 페이지번호를 클릭했을 떄다
					comm/board/list.jsp?page=3&opt=title&keyword=연습

	*/
	// 1. 요청 파라미터값을 조회한다.
	int currentPage = NumberUtils.toInt(request.getParameter("page"),1);
	int rows = NumberUtils.toInt(request.getParameter("rows"), 10);
	String sort = request.getParameter("sort");
	String opt = request.getParameter("opt");
	String keyword = request.getParameter("keyword");
	
	// 2. 검색에 필요한 정보를 담는Map를 생성한다.
	Map<String, Object> param = new HashMap<>();
	
	param.put("rows", rows);						//출력갯수를 Map에 저장한다.
	if(sort == null){								// 정렬방식이 없으면 date를 기본값으로 설정한다.
		sort="date";
	}
	param.put("sort", sort);						//정렬방식을 Map에 저장한다.
	
	if(opt !=null && !opt.isBlank()) {				//검색옵션을 Map에 저장한다.
		param.put("opt", opt);
	}
	if(keyword !=null && !keyword.isBlank()) {		//검색어를 Map에 저장한다.
		param.put("keyword", keyword);
		
	}
	System.out.println(param);
	
	
	
	// 2. COMM_BOARDS 테이블에 대한 CRUD 기능이 구현된 BoardDao객체를 생성한다.
	BoardDao boardDao = new BoardDao();
	
	// 3.전체 게시글 갯수를 조회한다.
	int totalRows = boardDao.getTotalRows(param);
	
	// 4 페이징 처리를 지원하는 pagination 객체를 생성한다.
	Pagination pagination = new Pagination(currentPage, totalRows, rows);
	
	// 5. 현재 페이지번호에 해당하는 게시글 목록 조회하기
	param.put("begin", pagination.getBegin());
	param.put("end", pagination.getEnd());
	
	System.out.println(param);
	List<Board> boardList = boardDao.getBoards(param);
	
	
%>
		<!--  선택된 옵션이 변경될때마다 화면이 변경하게 되므로 onchange로 이벤트 작성 -->
		<div class="d-flex justify-content-between my-3">
            <select class="form-select w-25" name="rows" onchange="changeRows()">
               <option value="10"<%=10 == rows ? "selected" : "" %>> 10개씩</option>
               <option value="20"<%=20 == rows ? "selected" : "" %>> 20개씩</option>
               <option value="50"<%=50 == rows ? "selected" : "" %>> 50개씩</option>
            </select>
            <select class="form-select w-25" name="sort" onchange="changeSort()">
               <option value="date"<%="date".equals(sort) ? "selected" : "" %>> 최신순</option>
               <option value="title"<%="title".equals(sort) ? "selected" : "" %>> 제목순</option>
               <option value="review"<%="review".equals(sort) ? "selected" : "" %>> 리뷰순</option>
               <option value="score"<%="score".equals(sort) ? "selected" : "" %>> 평점순</option>
            </select>
         </div>   
	
			
			<table class="table">
				<colgroup>
					<col width="10%">
					<col width="45%">
					<col width="15%">
					<col width="15%">
					<col width="15%">
				</colgroup>
				<thead>
					<tr>
						<th>번호</th>
						<th>제목</th>
						<th>작성자</th>
						<th>댓글갯수</th>
						<th>등록일</th>
					</tr>
				</thead>
				<tbody class="table-group-divider">
<%
	if(boardList.isEmpty()) {
%>
					<tr>
						<td colspan="5" class="text-center">게시글이 없습니다.</td>
					</tr>
<% 

	}else {
		for(Board board : boardList) {
%>
					<tr>
						<td><%=board.getNo() %></td>
						<td><a href="detail.jsp?no=<%=board.getNo() %>&page=<%=currentPage %>"><%=board.getTitle() %></a></td>
						<td><%=board.getUser().getName() %></td>
						<td><%=board.getReplyCnt() %></td>
						<td><%=DateUtils.toText(board.getCreatedDate()) %></td>
					</tr>
<%
		}
	}
%>
					
				</tbody>
			</table>
			
<%
 	/*
 		페이지 내비게이션 생성하기
 			1.시작페이지번호와 끝페이지번호를 조회해서 해당 범위만큼 표시한다.
 			2. 현재 요청한 페이지가 첫페이지인지, 마지막 페이지인지에 따라서 
 			   이전/다음 링크를 활성화/비활성화한다.
 	*/
 	int beginPage = pagination.getBeginPage();
	int endPage = pagination.getEndPage();
	
	boolean isFirst = pagination.isFirst();
	boolean isLast = pagination.isLast();
%>
			
			<nav>
				<ul class="pagination justify-content-center">
<%
	if(isFirst) {
%>
					<li class="page-item disabled">					
						<a class="page-link" href="">이전</a>
					</li>

<%
	}else{
%>
				<!-- 클릭시마다 어떤페이지를 보여줘야하는지확인 -->
			<li class="page-item">					
				<a class="page-link" href="list.jsp?page=<%=currentPage -1 %>"
				onclick="goPage(<%=currentPage -1 %>, event)">
				이전
				</a>
			</li>
					
<%
	}
%>
					
<%
	for(int num = beginPage; num <= endPage; num++){
%>
					
			<li class="page-item <%=currentPage == num ? "active" : ""%>">
				<a class="page-link" 
					href="list.jsp?page=<%=num %>"
					onclick="goPage(<%=num %>, event)"><%=num %></a>
			</li>
<%
	}
%>

<%
	if(isLast) {
%>
					<li class="page-item disabled">
						<a class="page-link" href="">다음</a>
					</li>
<%
	}else {
%>
						<li class="page-item">
						<a class="page-link" href="list.jsp?page=<%=currentPage + 1%>"
							onclick="goPage(<%=currentPage + 1%>, event)">다음</a>
					</li>
<%
	}
%>
				</ul>
			</nav>
			
			<div>
				<form id="form-search" class="row row-cols-sm-auto g-3 align-item-center"
				method ="get"
				action ="list.jsp">
				<input type="hidden" name="page" value="<%=currentPage%>"/>
				<input type="hidden" name="rows" value="<%=rows%>"/>
				<input type="hidden" name="sort" value="<%=sort %>"/>
					<div class="col-12">
						<select class="form-select" name="opt">
							<option value="title">선택하세요</option>
							<option value="title"<%="title".equals(opt) ? "selected" : "" %>>제목</option>
							<option value="writer" <%="writer".equals(opt)?"selected" : "" %>>작성자</option>
							<option value="content"<%="content".equals(opt) ? "selected" : "" %>>내용</option>
						</select>
					</div>
					<div class="col-12">
						<!--  검색어가 사리지 않게 하기위해서  -->
						<input type="text" class="form-control" name="keyword" value ="<%=keyword !=null ? keyword:""%>"/>
					</div>
					<div class="col-12">
					<!--  검색을 클릭하면 화면이 바뀌는것이 아니므로 onclick로 화면이바뀐다면 onchange로 (ex) 최신글순, 개시글 갯수 -->
						<button onclick="searchBoards();" type="button" class="btn btn-outline-primary">검색</button>
					</div>
				</form>				
			</div>
			
			<div class="text-end">
<%

	if(loginUser !=null) {
%>			
	<a class="btn btn-outline-primary" href="form.jsp">새 글</a>
		
<%
	}else {
%>
	<a class="btn btn-outline-primary disabled" aria-disabled="true" >새 글</a>


<%
	}
%>
			</div>
		</div>
	</div>
</div>
<script type="text/javascript">
	function changeRows() {
		// 검색폼의 히든 필드(name=page)를 1로 설정한다.
		document.querySelector("input[name=page]").value = 1;
		// 변경된 출력갯수를 조회한다.
		let rows = document.querySelector("select[name=rows]").value;
		// 검색폼의 히든필드(name=rows)에 변경된 출력갯수를 설정한다.
		document.querySelector("input[name=rows]").value = rows;
		// 검색 폼의 입력값(page, rows, sort, opt, keyword)을 서버로 제출한다.
		document.getElementById("form-search").submit();

	}
	
	function changeSort() {
		// 검색폼의 히든필드(name=page)를 1로설정한다.
		document.querySelector("input[name=page]").value = 1;
		// 변경된 정렬방식을 조회한다.
		let sort = document.querySelector("select[name=sort]").value;
		// 검색폼의 히든필드(name=sort)에 변경된 출력갯수를 설정한다.
		document.querySelector("input[name=sort]").value = sort;
		// 검색 폼의 입력값(page, rows, sort, opt, keyword)을 서버로 제출한다.
		document.getElementById("form-search").submit();


	}

	// 페이지 번호를 클릭했을 떄 실행되는 이벤트 핸들러 함수다.
	// 1. 검색폼의 page hidden 필드의 값을 전달받은 페이지값으로 설정한다
	// 2. 검색폼의 폼입력값을 서버로 제출시킨다.
	// * 페이지번호를 클릭 했을때 검색폼의 검색조건과 검색어도 함께 서버로 제출해야 한다.
	//   현재 보고 있는 페이지가 검색결과를 표시하는 페이지라면 검색조건, 검색어 그리고, 
	//	 클릭한 페이지번호도 전달되어야 한다.
	// * 따라서, 페이지번호를 클릭했을 떄도 검색폼을 제출해야한다.
	function goPage(page, event) {   //a태그를 누르면 다른화면으로 가기때문에 prventDefault작성
		event.preventDefault();
		
		document.querySelector("input[name=page]").value = page;
		document.getElementById("form-search").submit();
	}
	
	// 검색버튼을 클릭했을때 실행되는 이벤트핸드러 함수다.
	// 1. 검색폼의 page hidden 필드의 값을 1로 설정한다.
	// 2. 검색폼의 폼입력값을 서버로 제출 시킨다.
	// * 검색버튼을 클릭했을때는 언제나 검색결과에 대한 1페이지를 요청하는 것이기 때문에
	//   페이지번호를 1로 설정한다.
	function searchBoards() {
		document.querySelector("input[name=page]").value = 1;
		document.getElementById("form-search").submit();
		
	}
</script>
</body>
</html>


















