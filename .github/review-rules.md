# 코드 규칙

코딩 시 참조하는 규칙. 새 규칙은 해당 카테고리에 추가한다.

## 보안

(아직 추출된 규칙 없음)

## 코드 품질

- 여러 테이블을 조인하는 복잡한 단일 쿼리(한방 쿼리)보다 단계별 분리를 우선한다. 비즈니스 흐름이 애플리케이션 로직에 명시적으로 드러나야 한다. (예: 3개 이상 테이블 조인 + 서브쿼리가 포함된 경우 분리 대상)

## 스타일

- 변수명은 맥락을 함축하지 않는다. 축약 없이 의미가 명확하게 드러나도록 작성한다. (예: `col` X → `column` O / `bos` X → `outputStream` O / `wb` X → `workbook` O)
- 제어문(`for`, `if`) 중첩은 최대 3단계(depth)를 초과하지 않는다. 초과할 경우 별도 메서드로 분리하여 가독성을 확보한다.
- 반복 처리 시 로직이 단순하면 Stream API를 우선 사용한다. 로직이 복잡하여 Stream의 가독성이 저하되는 경우에 한해 for문을 허용한다.
- 코드 포맷팅은 Palantir Java Format을 사용한다. lint/format 규칙을 따른다.

## 아키텍처

- 정적 팩터리 메서드를 사용하여 객체를 생성한다. 의미가 다를 수 있으므로 여러 개가 존재할 수 있다. (예: `from(String)`, `fromCode(String)`, `fromJsonValue(String)`)

- Tell, Don't Ask 원칙을 따른다. 도메인 객체의 내부 데이터를 꺼내서 외부에서 판단하지 않고, 도메인 객체 내부에서 판단하여 결과를 반환한다. (예: `slot.isMockSlot()` O, `"Z".equals(slot.getSlotName())` X / `household.isMovedOutDuring(yearMonth)` O, `household.getMoveOutEndDate().isBefore(...)` X)
- 여러 Bounded Context의 도메인이 필요한 경우 ApplicationService에서 조합한다. 다른 Bounded Context의 Repository를 직접 참조하지 않고, 해당 BC의 DomainService 또는 ApplicationService를 통해 접근한다.
- 도메인 내부 생성자에서 Assertion으로 검증을 진행한다 (에러를 명확히 하기 위해)

## Enum

- `ordinal()` 사용을 금지한다. 순서가 바뀌면 의도치 않은 오류가 발생하므로, 순서가 필요한 경우 명시적으로 필드에 선언한다.
- `name()` 사용을 금지한다. enum 변수명이 변경되면 대응되지 않으므로, 외부 노출 값은 별도 필드로 관리한다.
- 외부 노출 값(JSON 직렬화 등)은 `label` 필드에 선언한다. (예: `DRAFT("draft")`, `COMPLETE("complete")`)

## 에러 처리

- Bounded Context별로 `ErrorCode` enum을 선언한다.

## 테스트

- 테스트 메서드명은 한국어로 작성한다. 숫자 및 영문은 포함될 수 있다. 단, Java 메서드명은 숫자로 시작할 수 없으므로 숫자로 시작하는 경우 언더스코어(`_`)를 접두사로 붙인다. 테스트 클래스에 `@SuppressWarnings("NonAsciiCharacters")`를 선언하여 경고를 억제한다.
- 테스트 메서드명은 동사 또는 동사구로 작성한다. (예: `전월_전체_거주_시_전액_부과한다()`)
- 한국어 메서드명이 테스트 설명을 대체하므로 `@DisplayName`은 사용하지 않는다. 단, `@Nested` 클래스에는 `@DisplayName`을 선언할 수 있다.
- Service/Facade 단 테스트는 `@SpringBootTest`를 활용한 통합 테스트로 진행한다. 외부 API만 mocking하고 나머지는 실제 빈을 사용한다.
